# IPTVAK - Apple TV IPTV Uygulaması 📺

Kendi M3U/M3U8 playlist'inizi ekleyerek Apple TV'nizde ücretsiz IPTV izleme deneyimi yaşayın!

## ✨ Özellikler

- 🔗 **M3U/M3U8 Playlist Desteği** - Herhangi bir IPTV playlist URL'si ekleyin
- 📂 **Otomatik Gruplama** - Kanallar kategorilere göre otomatik gruplandırılır
- ⭐ **Favoriler** - En sevdiğiniz kanalları favorilere ekleyin
- 🔍 **Arama** - Tüm kanallar arasında hızlı arama
- 🎨 **Modern Arayüz** - Apple TV'ye özel tasarlanmış güzel arayüz
- 📱 **Kolay Kullanım** - Siri Remote ile tam uyumlu
- 💾 **Otomatik Kaydetme** - Playlist ve favoriler otomatik kaydedilir
- 🔊 **HomePod Desteği** - Ses/görüntü senkronizasyonu optimize edilmiş
- ⚡ **Düşük Gecikme Modu** - HomePod'da ses gecikmesi sorunu çözüldü

## 🛠 Gereksinimler

- macOS Monterey veya üzeri
- Xcode 15.0 veya üzeri
- Apple Developer Hesabı (App Store yayını için)
- Apple TV (4. nesil veya üzeri) veya Apple TV 4K

## 🚀 Kurulum

### Xcode ile Derleme

1. `IPTVAK.xcodeproj` dosyasını Xcode ile açın
2. Team ayarlarını kendi Developer hesabınızla güncelleyin
3. Apple TV cihazınızı bağlayın veya tvOS Simulator'ı seçin
4. **Cmd + R** ile derleyin ve çalıştırın

### App Store'a Yükleme

1. Xcode'da **Product > Archive** seçin
2. **Distribute App** ile App Store Connect'e yükleyin
3. TestFlight veya App Store'da yayınlayın

## 📖 Kullanım

### Playlist Ekleme

1. Uygulamayı açın
2. **Ayarlar** sekmesine gidin
3. M3U playlist URL'nizi yapıştırın
4. **Playlist Yükle** butonuna basın

### Kanal İzleme

1. **Kanallar** sekmesinden bir grup seçin
2. İzlemek istediğiniz kanala tıklayın
3. Video otomatik başlayacaktır

### Favorilere Ekleme

1. Herhangi bir kanala uzun basın (veya sağ tıklayın)
2. **Favorilere Ekle** seçin
3. Favori kanallarınız **Favoriler** sekmesinde görünecek

### HomePod Ses Ayarları

HomePod'da ses gecikmesi (lip-sync) sorunu yaşıyorsanız:

1. **Ayarlar** sekmesine gidin
2. **HomePod & Ses Ayarları** bölümünü bulun
3. **Düşük Gecikme Modu**'nu açık tutun
4. Donma yaşarsanız **Buffer Süresi**'ni artırın (2-3 saniye önerilir)

> 💡 **İpucu**: HomePod bağlıyken uygulama otomatik olarak bunu algılar ve optimize eder.

## 📁 Proje Yapısı

```
IPTVAK/
├── IPTVAK/
│   ├── IPTVAKApp.swift          # Ana uygulama girişi
│   ├── ContentView.swift         # Ana görünüm ve tab yapısı
│   ├── Info.plist                # Uygulama ayarları
│   ├── Models/
│   │   └── Channel.swift         # Kanal ve Grup modelleri
│   ├── Views/
│   │   ├── GroupListView.swift   # Grup listesi görünümü
│   │   ├── ChannelListView.swift # Kanal listesi görünümü
│   │   ├── PlayerView.swift      # Video oynatıcı
│   │   ├── SettingsView.swift    # Ayarlar ekranı
│   │   └── ChannelRowView.swift  # Kanal kart bileşenleri
│   ├── Managers/
│   │   ├── M3UParser.swift       # M3U dosya ayrıştırıcı
│   │   ├── PlaylistManager.swift # Playlist yönetimi
│   │   └── FavoritesManager.swift# Favori yönetimi
│   └── Assets.xcassets/          # Görseller ve renkler
└── IPTVAK.xcodeproj/             # Xcode proje dosyası
```

## 🔧 Özelleştirme

### Renk Teması Değiştirme
`Assets.xcassets/AccentColor.colorset/Contents.json` dosyasını düzenleyin.

### Desteklenen Stream Formatları
- HLS (.m3u8)
- HTTP Streams
- RTMP
- RTSP

## ⚠️ Önemli Notlar

- Bu uygulama yasal IPTV servisleriyle kullanılmak üzere tasarlanmıştır
- Telif hakkı korunan içeriklerin izinsiz yayını yasaktır
- IPTV sağlayıcınızın kullanım şartlarına uyduğunuzdan emin olun

## 📄 Lisans

Bu proje kişisel kullanım için ücretsizdir.

## 🤝 Katkıda Bulunma

1. Bu repoyu fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik ekle'`)
4. Branch'inizi push edin (`git push origin feature/yeni-ozellik`)
5. Pull Request açın

---

**IPTVAK** ile keyifli seyirler! 🎬
