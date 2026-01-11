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
                VideoPlayerView(player: player)
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
        #if os(tvOS)
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
        #else
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    favoritesManager.toggleFavorite(channel.id)
                } label: {
                    Image(systemName: favoritesManager.isFavorite(channel.id) ? "star.fill" : "star")
                        .foregroundColor(favoritesManager.isFavorite(channel.id) ? .yellow : .gray)
                }
            }
        }
        #endif
        .navigationTitle(channel.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            // Kanal logosu
            if let logoURL = channel.logoURL, let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                    default:
                        channelIcon
                    }
                }
            } else {
                channelIcon
            }
            
            Text(channel.name)
                .font(.title2)
                .fontWeight(.bold)
            
            ProgressView()
                .scaleEffect(1.2)
            
            Text(L10n.Player.loading)
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: errorIconSize))
                .foregroundColor(.orange)
            
            Text(L10n.Player.errorTitle)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .font(.subheadline)
            
            Button(L10n.Player.retry) {
                hasError = false
                isLoading = true
                setupPlayer()
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - Platform-specific sizes
    private var iconSize: CGFloat {
        #if os(tvOS)
        return 150
        #else
        return 80
        #endif
    }
    
    private var errorIconSize: CGFloat {
        #if os(tvOS)
        return 80
        #else
        return 50
        #endif
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
                .frame(width: iconSize, height: iconSize)
            
            Text(channel.name.prefix(2).uppercased())
                .font(.system(size: iconSize * 0.35, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Audio Session Konfigürasyonu
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // HomePod ve diğer AirPlay cihazları için optimize edilmiş ayarlar
            try audioSession.setCategory(
                .playback,
                mode: .moviePlayback,
                options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP]
            )
            
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("✅ Audio session yapılandırıldı")
        } catch {
            print("⚠️ Audio session hatası: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Player Setup
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
        
        // Buffer ayarları
        playerItem.preferredForwardBufferDuration = bufferDuration
        
        // Canlı yayınlar için gecikmeyi minimize et
        if #available(iOS 15.0, tvOS 15.0, *) {
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
        
        // Player ayarları
        newPlayer.automaticallyWaitsToMinimizeStalling = !lowLatencyMode
        newPlayer.allowsExternalPlayback = true
        
        #if os(tvOS)
        newPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true
        #endif
        
        if #available(iOS 15.0, tvOS 15.0, *) {
            newPlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        // Oynatıcıyı başlat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.player = newPlayer
            self.isLoading = false
            newPlayer.playImmediately(atRate: 1.0)
        }
    }
    
    // MARK: - Player Temizleme
    private func cleanupPlayer() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Video Player (Cross-platform)
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        
        #if os(iOS)
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        #endif
        
        #if os(tvOS)
        controller.allowsPictureInPicturePlayback = true
        controller.appliesPreferredDisplayCriteriaAutomatically = true
        #endif
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player !== player {
            uiViewController.player = player
        }
    }
}

// MARK: - Ses Senkronizasyon Yardımcısı
class AudioSyncManager {
    static let shared = AudioSyncManager()
    
    private init() {}
    
    var isHomePodConnected: Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        
        for output in currentRoute.outputs {
            if output.portType == .airPlay {
                return true
            }
        }
        return false
    }
    
    func getAudioLatency() -> TimeInterval {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.outputLatency + audioSession.inputLatency
    }
    
    var recommendedBufferDuration: TimeInterval {
        if isHomePodConnected {
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
