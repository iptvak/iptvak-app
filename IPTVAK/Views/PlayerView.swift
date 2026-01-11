import SwiftUI
import AVKit
import AVFoundation

struct PlayerView: View {
    let channel: Channel
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var errorMessage = ""
    
    // Kullanıcı ayarları (HomePod optimizasyonu)
    @AppStorage("lowLatencyMode") private var lowLatencyMode = true
    @AppStorage("bufferDuration") private var bufferDuration = 2.0
    
    var body: some View {
        ZStack {
            // Arka plan
            Color.black.ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if hasError {
                errorView
            } else if let player = player {
                // AVPlayerViewController kullanarak daha iyi HomePod desteği
                TVVideoPlayer(player: player)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            configureAudioSession()
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    favoritesManager.toggleFavorite(channel.id)
                } label: {
                    Image(systemName: favoritesManager.isFavorite(channel.id) ? "star.fill" : "star")
                        .foregroundColor(favoritesManager.isFavorite(channel.id) ? .yellow : .white)
                }
            }
        }
        .navigationTitle(channel.name)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 30) {
            // Kanal logosu
            if let logoURL = channel.logoURL, let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                    default:
                        channelIcon
                    }
                }
            } else {
                channelIcon
            }
            
            Text(channel.name)
                .font(.title)
                .fontWeight(.bold)
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text(L10n.Player.loading)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text(L10n.Player.errorTitle)
                .font(.title)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            
            Button(L10n.Player.retry) {
                hasError = false
                isLoading = true
                setupPlayer()
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - Kanal İkonu
    private var channelIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 150, height: 150)
            
            Text(channel.name.prefix(2).uppercased())
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Audio Session Konfigürasyonu (HomePod için kritik!)
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // HomePod ve diğer AirPlay cihazları için optimize edilmiş ayarlar
            try audioSession.setCategory(
                .playback,
                mode: .moviePlayback,
                options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP]
            )
            
            // Ses senkronizasyonu için buffer policy
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("✅ Audio session HomePod için yapılandırıldı")
        } catch {
            print("⚠️ Audio session hatası: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Player Setup (HomePod Optimizasyonlu)
    private func setupPlayer() {
        guard let url = URL(string: channel.streamURL) else {
            hasError = true
            errorMessage = L10n.Player.errorInvalidURL
            isLoading = false
            return
        }
        
        // Asset oluştur
        let asset = AVURLAsset(url: url, options: [
            AVURLAssetPreferPreciseDurationAndTimingKey: true
        ])
        
        let playerItem = AVPlayerItem(asset: asset)
        
        // ✅ HomePod ses senkronizasyonu için kritik ayarlar
        // Kullanıcının ayarladığı buffer süresini kullan
        playerItem.preferredForwardBufferDuration = bufferDuration
        
        // Canlı yayınlar için gecikmeyi minimize et
        if #available(tvOS 15.0, *) {
            playerItem.configuredTimeOffsetFromLive = CMTime(seconds: 2.0, preferredTimescale: 1)
            playerItem.automaticallyPreservesTimeOffsetFromLive = true
        }
        
        // Ses/Video senkronizasyonu için
        playerItem.audioTimePitchAlgorithm = .timeDomain
        
        // Hata dinleyicisi
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { notification in
            if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                hasError = true
                errorMessage = error.localizedDescription
            }
        }
        
        let newPlayer = AVPlayer(playerItem: playerItem)
        
        // ✅ HomePod için kritik player ayarları
        // Düşük gecikme modunda otomatik beklemeyi kapat
        newPlayer.automaticallyWaitsToMinimizeStalling = !lowLatencyMode
        
        // AirPlay için ses senkronizasyonunu aktifleştir
        newPlayer.allowsExternalPlayback = true
        newPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true
        
        // Master clock senkronizasyonu (HomePod için önemli)
        if #available(tvOS 15.0, *) {
            newPlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        // Oynatıcıyı başlat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.player = newPlayer
            self.isLoading = false
            
            // Rate'i 1.0 olarak ayarla ve başlat
            newPlayer.playImmediately(atRate: 1.0)
        }
    }
    
    // MARK: - Player Temizleme
    private func cleanupPlayer() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        
        // Notification'ları temizle
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - tvOS Video Player (AVPlayerViewController ile HomePod desteği)
struct TVVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.allowsPictureInPicturePlayback = true
        
        // ✅ HomePod ses senkronizasyonu için
        controller.appliesPreferredDisplayCriteriaAutomatically = true
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Player değişirse güncelle
        if uiViewController.player !== player {
            uiViewController.player = player
        }
    }
}

// MARK: - Ses Senkronizasyon Yardımcısı
class AudioSyncManager {
    static let shared = AudioSyncManager()
    
    private init() {}
    
    /// HomePod bağlı mı kontrol et
    var isHomePodConnected: Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        
        for output in currentRoute.outputs {
            // AirPlay cihazı (HomePod dahil)
            if output.portType == .airPlay {
                return true
            }
        }
        return false
    }
    
    /// Ses gecikmesini hesapla
    func getAudioLatency() -> TimeInterval {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.outputLatency + audioSession.inputLatency
    }
    
    /// HomePod için önerilen buffer süresi
    var recommendedBufferDuration: TimeInterval {
        if isHomePodConnected {
            // HomePod bağlıyken daha kısa buffer (daha az gecikme)
            return 1.5
        }
        return 3.0
    }
}

#Preview {
    NavigationStack {
        PlayerView(channel: Channel(
            name: "Test Kanal",
            streamURL: "https://test.com/stream.m3u8"
        ))
        .environmentObject(FavoritesManager())
    }
}
