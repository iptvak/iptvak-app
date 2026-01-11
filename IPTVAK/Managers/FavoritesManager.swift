import Foundation
import SwiftUI

@MainActor
class FavoritesManager: ObservableObject {
    @Published var favoriteIDs: Set<String> = []
    
    private let favoritesKey = "favoriteChannels"
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Favori Kontrolü
    
    func isFavorite(_ channelID: String) -> Bool {
        favoriteIDs.contains(channelID)
    }
    
    // MARK: - Favori Ekleme/Çıkarma
    
    func toggleFavorite(_ channelID: String) {
        if favoriteIDs.contains(channelID) {
            favoriteIDs.remove(channelID)
        } else {
            favoriteIDs.insert(channelID)
        }
        saveFavorites()
    }
    
    func addFavorite(_ channelID: String) {
        favoriteIDs.insert(channelID)
        saveFavorites()
    }
    
    func removeFavorite(_ channelID: String) {
        favoriteIDs.remove(channelID)
        saveFavorites()
    }
    
    // MARK: - Kaydetme & Yükleme
    
    private func saveFavorites() {
        let array = Array(favoriteIDs)
        UserDefaults.standard.set(array, forKey: favoritesKey)
    }
    
    private func loadFavorites() {
        if let array = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteIDs = Set(array)
        }
    }
    
    // MARK: - Tümünü Temizle
    
    func clearAllFavorites() {
        favoriteIDs.removeAll()
        saveFavorites()
    }
}
