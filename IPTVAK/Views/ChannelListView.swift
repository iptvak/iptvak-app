import SwiftUI

struct ChannelListView: View {
    let group: ChannelGroup
    @EnvironmentObject var playlistManager: PlaylistManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 280, maximum: 350), spacing: 35)
            ], spacing: 35) {
                ForEach(group.channels) { channel in
                    NavigationLink(destination: PlayerView(channel: channel)) {
                        ChannelCardView(channel: channel)
                    }
                    .buttonStyle(CardButtonStyle())
                    .contextMenu {
                        // Favorilere Ekle/Çıkar
                        Button {
                            favoritesManager.toggleFavorite(channel.id)
                        } label: {
                            Label(
                                favoritesManager.isFavorite(channel.id) ? L10n.Favorites.remove : L10n.Favorites.add,
                                systemImage: favoritesManager.isFavorite(channel.id) ? "star.slash" : "star"
                            )
                        }
                    }
                }
            }
            .padding(50)
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Text(L10n.Channels.count(group.channels.count))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Satır Görünümü (List için alternatif)
struct ChannelRowView: View {
    let channel: Channel
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        HStack(spacing: 20) {
            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.5, brightness: 0.4),
                                Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.7, brightness: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 60)
                
                if let logoURL = channel.logoURL, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 40)
                        default:
                            Text(channel.name.prefix(2).uppercased())
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    Text(channel.name.prefix(2).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // İsim
            VStack(alignment: .leading, spacing: 4) {
                Text(channel.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(channel.group)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Favori ikonu
            if favoritesManager.isFavorite(channel.id) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        ChannelListView(group: ChannelGroup(name: "Test", channels: [
            Channel(name: "Test Kanal 1", streamURL: "http://test.com/1"),
            Channel(name: "Test Kanal 2", streamURL: "http://test.com/2")
        ]))
        .environmentObject(PlaylistManager())
        .environmentObject(FavoritesManager())
    }
}
