import SwiftUI

struct ContentView: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Ana Sayfa - Tüm Kanallar
            NavigationStack {
                GroupListView()
                    .navigationTitle(L10n.App.title)
            }
            .tabItem {
                Label(L10n.Tab.channels, systemImage: "tv")
            }
            .tag(0)
            
            // Favoriler
            NavigationStack {
                FavoritesView()
                    .navigationTitle(L10n.Favorites.title)
            }
            .tabItem {
                Label(L10n.Tab.favorites, systemImage: "star.fill")
            }
            .tag(1)
            
            // Arama
            NavigationStack {
                SearchView()
                    .navigationTitle(L10n.Search.title)
            }
            .tabItem {
                Label(L10n.Tab.search, systemImage: "magnifyingglass")
            }
            .tag(2)
            
            // Ayarlar
            NavigationStack {
                SettingsView()
                    .navigationTitle(L10n.Settings.title)
            }
            .tabItem {
                Label(L10n.Tab.settings, systemImage: "gear")
            }
            .tag(3)
        }
        .tint(Color("AccentColor"))
    }
}

// MARK: - Favoriler View
struct FavoritesView: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var favoriteChannels: [Channel] {
        playlistManager.channels.filter { favoritesManager.isFavorite($0.id) }
    }
    
    var body: some View {
        if favoriteChannels.isEmpty {
            ContentUnavailableView(
                L10n.Favorites.emptyTitle,
                systemImage: "star.slash",
                description: Text(L10n.Favorites.emptyDescription)
            )
        } else {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 40)
                ], spacing: 40) {
                    ForEach(favoriteChannels) { channel in
                        NavigationLink(destination: PlayerView(channel: channel)) {
                            ChannelCardView(channel: channel)
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                }
                .padding(50)
            }
        }
    }
}

// MARK: - Arama View
struct SearchView: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    @State private var searchText = ""
    
    var filteredChannels: [Channel] {
        if searchText.isEmpty {
            return []
        }
        return playlistManager.channels.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack {
            if filteredChannels.isEmpty && !searchText.isEmpty {
                ContentUnavailableView(
                    L10n.Search.notFoundTitle,
                    systemImage: "tv.slash",
                    description: Text(L10n.Search.notFoundDescription(searchText))
                )
            } else if searchText.isEmpty {
                ContentUnavailableView(
                    L10n.Search.emptyTitle,
                    systemImage: "magnifyingglass",
                    description: Text(L10n.Search.emptyDescription)
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 40)
                    ], spacing: 40) {
                        ForEach(filteredChannels) { channel in
                            NavigationLink(destination: PlayerView(channel: channel)) {
                                ChannelCardView(channel: channel)
                            }
                            .buttonStyle(CardButtonStyle())
                        }
                    }
                    .padding(50)
                }
            }
        }
        .searchable(text: $searchText, prompt: L10n.Search.prompt)
    }
}

// MARK: - Kanal Kart Görünümü
struct ChannelCardView: View {
    let channel: Channel
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.6, brightness: 0.3),
                                Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.8, brightness: 0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                
                if let logoURL = channel.logoURL, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                        case .failure(_):
                            channelInitials
                        case .empty:
                            ProgressView()
                        @unknown default:
                            channelInitials
                        }
                    }
                } else {
                    channelInitials
                }
                
                // Favori ikonu
                if favoritesManager.isFavorite(channel.id) {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                                .padding(12)
                        }
                        Spacer()
                    }
                }
            }
            
            Text(channel.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(width: 300)
    }
    
    var channelInitials: some View {
        Text(channel.name.prefix(2).uppercased())
            .font(.system(size: 50, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(0.9))
    }
}

// MARK: - Kart Button Style
struct CardButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .environmentObject(PlaylistManager())
        .environmentObject(FavoritesManager())
}
