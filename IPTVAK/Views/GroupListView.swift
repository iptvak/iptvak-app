import SwiftUI

struct GroupListView: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        Group {
            if playlistManager.isLoading {
                loadingView
            } else if playlistManager.channels.isEmpty {
                emptyView
            } else {
                channelGroupsView
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(2)
            Text(L10n.Channels.loading)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        ContentUnavailableView(
            L10n.Channels.emptyTitle,
            systemImage: "tv.slash",
            description: Text(L10n.Channels.emptyDescription)
        )
    }
    
    // MARK: - Kanal Grupları
    private var channelGroupsView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 50) {
                ForEach(playlistManager.groups) { group in
                    VStack(alignment: .leading, spacing: 20) {
                        // Grup Başlığı
                        HStack {
                            Text(group.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("(\(group.channels.count))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            NavigationLink(destination: ChannelListView(group: group)) {
                                Text(L10n.Channels.seeAll)
                                    .font(.callout)
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                        .padding(.horizontal, 50)
                        
                        // Yatay Kanal Listesi
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 30) {
                                ForEach(group.channels.prefix(10)) { channel in
                                    NavigationLink(destination: PlayerView(channel: channel)) {
                                        ChannelCardView(channel: channel)
                                    }
                                    .buttonStyle(CardButtonStyle())
                                    .contextMenu {
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
                            .padding(.horizontal, 50)
                        }
                    }
                }
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview {
    NavigationStack {
        GroupListView()
            .environmentObject(PlaylistManager())
            .environmentObject(FavoritesManager())
    }
}
