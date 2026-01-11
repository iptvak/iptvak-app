import SwiftUI
import AVFoundation

struct SettingsView: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @State private var playlistURL: String = ""
    @State private var showingClearConfirmation = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    
    // HomePod / Ses Ayarları
    @AppStorage("lowLatencyMode") private var lowLatencyMode = true
    @AppStorage("bufferDuration") private var bufferDuration = 2.0
    @State private var isHomePodConnected = false
    @State private var audioLatency: TimeInterval = 0
    
    var body: some View {
        List {
            // MARK: - Playlist Bölümü
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.Settings.Playlist.url)
                        .font(.headline)
                    
                    TextField(L10n.Settings.Playlist.urlPlaceholder, text: $playlistURL)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    HStack(spacing: 20) {
                        Button {
                            Task {
                                await loadPlaylist()
                            }
                        } label: {
                            HStack {
                                if playlistManager.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.down.circle.fill")
                                }
                                Text(L10n.Settings.Playlist.load)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(playlistURL.isEmpty || playlistManager.isLoading)
                        
                        if !playlistManager.playlistURL.isEmpty {
                            Button {
                                Task {
                                    await playlistManager.refreshPlaylist()
                                    showingSuccessAlert = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text(L10n.Settings.Playlist.refresh)
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(playlistManager.isLoading)
                        }
                    }
                }
                .padding(.vertical, 10)
            } header: {
                Label(L10n.Settings.Playlist.title, systemImage: "list.bullet")
            } footer: {
                if let error = playlistManager.error {
                    Text(L10n.Settings.Playlist.error(error))
                        .foregroundColor(.red)
                } else if !playlistManager.playlistURL.isEmpty {
                    Text(L10n.Settings.Playlist.active(playlistManager.playlistURL))
                        .foregroundColor(.secondary)
                }
            }
            
            // MARK: - HomePod / Ses Ayarları
            Section {
                // Bağlantı durumu
                HStack {
                    Label(L10n.Settings.Audio.homepod, systemImage: isHomePodConnected ? "homepod.fill" : "homepod")
                    Spacer()
                    Text(isHomePodConnected ? L10n.Settings.Audio.connected : L10n.Settings.Audio.notConnected)
                        .foregroundColor(isHomePodConnected ? .green : .secondary)
                }
                
                // Düşük gecikme modu
                Toggle(isOn: $lowLatencyMode) {
                    Label(L10n.Settings.Audio.lowLatency, systemImage: "waveform.path")
                }
                .onChange(of: lowLatencyMode) { _, newValue in
                    bufferDuration = newValue ? 1.5 : 3.0
                }
                
                // Buffer süresi
                HStack {
                    Label(L10n.Settings.Audio.buffer, systemImage: "timer")
                    Spacer()
                    
                    // tvOS'ta Slider yok, butonlarla kontrol
                    Button {
                        if bufferDuration > 0.5 {
                            bufferDuration -= 0.5
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    
                    Text(L10n.Settings.Audio.bufferValue(bufferDuration))
                        .frame(width: 80)
                        .foregroundColor(.secondary)
                    
                    Button {
                        if bufferDuration < 5.0 {
                            bufferDuration += 0.5
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
                
                // Gecikme bilgisi
                if audioLatency > 0 {
                    HStack {
                        Label(L10n.Settings.Audio.latency, systemImage: "clock.arrow.2.circlepath")
                        Spacer()
                        Text(L10n.Settings.Audio.latencyValue(audioLatency * 1000))
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Label(L10n.Settings.Audio.title, systemImage: "hifispeaker.2.fill")
            } footer: {
                Text(L10n.Settings.Audio.footer)
            }
            
            // MARK: - İstatistikler
            Section {
                HStack {
                    Label(L10n.Settings.Stats.totalChannels, systemImage: "tv")
                    Spacer()
                    Text("\(playlistManager.channels.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(L10n.Settings.Stats.groups, systemImage: "folder")
                    Spacer()
                    Text("\(playlistManager.groups.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(L10n.Settings.Stats.favorites, systemImage: "star.fill")
                    Spacer()
                    Text("\(favoritesManager.favoriteIDs.count)")
                        .foregroundColor(.secondary)
                }
            } header: {
                Label(L10n.Settings.Stats.title, systemImage: "chart.bar")
            }
            
            // MARK: - Temizleme
            Section {
                Button(role: .destructive) {
                    showingClearConfirmation = true
                } label: {
                    Label(L10n.Settings.Data.clearAll, systemImage: "trash")
                }
            } header: {
                Label(L10n.Settings.Data.title, systemImage: "externaldrive")
            } footer: {
                Text(L10n.Settings.Data.footer)
            }
            
            // MARK: - Hakkında
            Section {
                HStack {
                    Text(L10n.Settings.About.version)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(L10n.Settings.About.developer)
                    Spacer()
                    Text("IPTVAK")
                        .foregroundColor(.secondary)
                }
            } header: {
                Label(L10n.Settings.About.title, systemImage: "info.circle")
            }
        }
        .onAppear {
            playlistURL = playlistManager.playlistURL
            checkHomePodConnection()
        }
        .alert(L10n.Alert.success, isPresented: $showingSuccessAlert) {
            Button(L10n.Alert.ok, role: .cancel) { }
        } message: {
            Text(L10n.Alert.successLoaded(playlistManager.channels.count))
        }
        .alert(L10n.Settings.Data.clearConfirmTitle, isPresented: $showingClearConfirmation) {
            Button(L10n.Settings.Data.clearConfirmCancel, role: .cancel) { }
            Button(L10n.Settings.Data.clearConfirmDelete, role: .destructive) {
                clearAllData()
            }
        } message: {
            Text(L10n.Settings.Data.clearConfirmMessage)
        }
    }
    
    // MARK: - Fonksiyonlar
    
    private func loadPlaylist() async {
        await playlistManager.loadPlaylist(from: playlistURL)
        if playlistManager.error == nil {
            showingSuccessAlert = true
        }
    }
    
    private func clearAllData() {
        playlistManager.clearPlaylist()
        favoritesManager.clearAllFavorites()
        playlistURL = ""
    }
    
    // MARK: - HomePod Bağlantı Kontrolü
    private func checkHomePodConnection() {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        
        // AirPlay/HomePod kontrolü
        isHomePodConnected = currentRoute.outputs.contains { output in
            output.portType == .airPlay || 
            output.portType == .bluetoothA2DP ||
            output.portType == .bluetoothLE
        }
        
        // Gecikme hesapla
        audioLatency = audioSession.outputLatency
        
        // Bağlantı değişikliğini dinle
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            checkHomePodConnection()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(PlaylistManager())
            .environmentObject(FavoritesManager())
    }
}
