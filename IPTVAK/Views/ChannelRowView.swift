import SwiftUI

// Bu dosya ChannelListView.swift içinde tanımlandı
// Ek bileşenler buraya eklenebilir

// MARK: - Kanal Grid Item
struct ChannelGridItem: View {
    let channel: Channel
    let isFavorite: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Logo Alanı
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.5, brightness: 0.35),
                                Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.7, brightness: 0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                
                if let logoURL = channel.logoURL, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 90)
                        case .failure(_):
                            Text(channel.name.prefix(2).uppercased())
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text(channel.name.prefix(2).uppercased())
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Favori badge
                if isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            
            // Kanal Adı
            Text(channel.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(width: 200)
    }
}

// MARK: - Kanal Banner (Büyük görünüm)
struct ChannelBannerView: View {
    let channel: Channel
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Arka plan gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.6, brightness: 0.4),
                            Color(hue: Double(channel.name.hashValue % 360) / 360, saturation: 0.8, brightness: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Logo (sağ üstte)
            VStack {
                HStack {
                    Spacer()
                    if let logoURL = channel.logoURL, let url = URL(string: logoURL) {
                        AsyncImage(url: url) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            }
                        }
                        .padding()
                    }
                }
                Spacer()
            }
            
            // İçerik
            VStack(alignment: .leading, spacing: 8) {
                // Favori ikonu
                if favoritesManager.isFavorite(channel.id) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Favori")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(channel.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(channel.group)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(24)
        }
        .frame(height: 200)
    }
}

#Preview {
    VStack(spacing: 30) {
        ChannelGridItem(
            channel: Channel(name: "Test Kanal", streamURL: "http://test.com"),
            isFavorite: true
        )
        
        ChannelBannerView(
            channel: Channel(name: "Test Kanal Uzun İsim", streamURL: "http://test.com", group: "Spor")
        )
        .environmentObject(FavoritesManager())
        .frame(width: 400)
    }
    .padding()
}
