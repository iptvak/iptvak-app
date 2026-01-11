import SwiftUI

@main
struct IPTVAKApp: App {
    @StateObject private var playlistManager = PlaylistManager()
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playlistManager)
                .environmentObject(favoritesManager)
                .preferredColorScheme(.dark)
        }
    }
}
