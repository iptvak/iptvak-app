import Foundation
import SwiftUI

@MainActor
class PlaylistManager: ObservableObject {
    @Published var channels: [Channel] = []
    @Published var groups: [ChannelGroup] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var playlistURL: String = ""
    
    private let userDefaultsKey = "savedPlaylistURL"
    private let channelsKey = "savedChannels"
    private let channelOrderKey = "channelOrder"
    
    init() {
        loadSavedPlaylist()
    }
    
    // MARK: - Playlist Yükleme
    
    func loadPlaylist(from urlString: String) async {
        isLoading = true
        error = nil
        
        do {
            let parsedChannels = try await M3UParser.parseFromURL(urlString)
            
            // Kaydedilmiş sıralama var mı kontrol et
            let orderedChannels = applyCustomOrder(to: parsedChannels)
            
            self.channels = orderedChannels
            self.groups = groupChannels(orderedChannels)
            self.playlistURL = urlString
            
            // Kaydet
            savePlaylistURL(urlString)
            saveChannels(orderedChannels)
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Kaydetme & Yükleme
    
    private func savePlaylistURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: userDefaultsKey)
    }
    
    private func saveChannels(_ channels: [Channel]) {
        if let encoded = try? JSONEncoder().encode(channels) {
            UserDefaults.standard.set(encoded, forKey: channelsKey)
        }
    }
    
    private func loadSavedPlaylist() {
        // Önce kaydedilmiş kanalları yükle
        if let data = UserDefaults.standard.data(forKey: channelsKey),
           let savedChannels = try? JSONDecoder().decode([Channel].self, from: data) {
            self.channels = savedChannels
            self.groups = groupChannels(savedChannels)
        }
        
        // URL'yi de yükle
        if let savedURL = UserDefaults.standard.string(forKey: userDefaultsKey) {
            self.playlistURL = savedURL
        }
    }
    
    // MARK: - Gruplama
    
    private func groupChannels(_ channels: [Channel]) -> [ChannelGroup] {
        var groupDict: [String: [Channel]] = [:]
        
        for channel in channels {
            if groupDict[channel.group] == nil {
                groupDict[channel.group] = []
            }
            groupDict[channel.group]?.append(channel)
        }
        
        // Grupları alfabetik sırala, ama "General/Genel/Общее" en üstte olsun
        let generalGroup = L10n.General.group
        return groupDict.map { ChannelGroup(name: $0.key, channels: $0.value) }
            .sorted { g1, g2 in
                if g1.name == generalGroup { return true }
                if g2.name == generalGroup { return false }
                return g1.name < g2.name
            }
    }
    
    // MARK: - Kanal Sıralama
    
    func moveChannel(from source: IndexSet, to destination: Int, in groupName: String) {
        guard let groupIndex = groups.firstIndex(where: { $0.name == groupName }) else { return }
        
        var updatedChannels = groups[groupIndex].channels
        updatedChannels.move(fromOffsets: source, toOffset: destination)
        
        // Order'ları güncelle
        for (index, var channel) in updatedChannels.enumerated() {
            channel.order = index
            if let mainIndex = channels.firstIndex(where: { $0.id == channel.id }) {
                channels[mainIndex].order = index
            }
        }
        
        groups[groupIndex].channels = updatedChannels
        saveChannels(channels)
    }
    
    private func applyCustomOrder(to channels: [Channel]) -> [Channel] {
        // Eğer kaydedilmiş sıralama varsa uygula
        guard let data = UserDefaults.standard.data(forKey: channelOrderKey),
              let orderMap = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return channels
        }
        
        var orderedChannels = channels
        for (index, var channel) in orderedChannels.enumerated() {
            if let savedOrder = orderMap[channel.id] {
                channel.order = savedOrder
                orderedChannels[index] = channel
            }
        }
        
        return orderedChannels.sorted { $0.order < $1.order }
    }
    
    // MARK: - Playlist Silme
    
    func clearPlaylist() {
        channels = []
        groups = []
        playlistURL = ""
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: channelsKey)
        UserDefaults.standard.removeObject(forKey: channelOrderKey)
    }
    
    // MARK: - Playlist Yenile
    
    func refreshPlaylist() async {
        guard !playlistURL.isEmpty else { return }
        await loadPlaylist(from: playlistURL)
    }
}
