import Foundation
import SwiftUI

// MARK: - Localization Helper
extension String {
    /// Localizable.strings'den çeviri al
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Argümanlı çeviri
    func localized(_ args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}

// MARK: - Localization Keys
struct L10n {
    // Tab Bar
    struct Tab {
        static let channels = "tab.channels".localized
        static let favorites = "tab.favorites".localized
        static let search = "tab.search".localized
        static let settings = "tab.settings".localized
    }
    
    // App
    struct App {
        static let title = "app.title".localized
    }
    
    // Channels
    struct Channels {
        static let emptyTitle = "channels.empty.title".localized
        static let emptyDescription = "channels.empty.description".localized
        static let loading = "channels.loading".localized
        static func count(_ count: Int) -> String { "channels.count".localized(count) }
        static let seeAll = "channels.seeAll".localized
    }
    
    // Favorites
    struct Favorites {
        static let title = "favorites.title".localized
        static let emptyTitle = "favorites.empty.title".localized
        static let emptyDescription = "favorites.empty.description".localized
        static let add = "favorites.add".localized
        static let remove = "favorites.remove".localized
    }
    
    // Search
    struct Search {
        static let title = "search.title".localized
        static let prompt = "search.prompt".localized
        static let emptyTitle = "search.empty.title".localized
        static let emptyDescription = "search.empty.description".localized
        static let notFoundTitle = "search.notFound.title".localized
        static func notFoundDescription(_ query: String) -> String { "search.notFound.description".localized(query) }
    }
    
    // Player
    struct Player {
        static let loading = "player.loading".localized
        static let errorTitle = "player.error.title".localized
        static let errorInvalidURL = "player.error.invalidURL".localized
        static let retry = "player.retry".localized
    }
    
    // Settings
    struct Settings {
        static let title = "settings.title".localized
        
        struct Playlist {
            static let title = "settings.playlist.title".localized
            static let url = "settings.playlist.url".localized
            static let urlPlaceholder = "settings.playlist.urlPlaceholder".localized
            static let load = "settings.playlist.load".localized
            static let refresh = "settings.playlist.refresh".localized
            static func active(_ url: String) -> String { "settings.playlist.active".localized(url) }
            static func error(_ msg: String) -> String { "settings.playlist.error".localized(msg) }
        }
        
        struct Audio {
            static let title = "settings.audio.title".localized
            static let homepod = "settings.audio.homepod".localized
            static let connected = "settings.audio.connected".localized
            static let notConnected = "settings.audio.notConnected".localized
            static let lowLatency = "settings.audio.lowLatency".localized
            static let buffer = "settings.audio.buffer".localized
            static func bufferValue(_ val: Double) -> String { String(format: "settings.audio.bufferValue".localized, val) }
            static let latency = "settings.audio.latency".localized
            static func latencyValue(_ val: Double) -> String { String(format: "settings.audio.latencyValue".localized, val) }
            static let footer = "settings.audio.footer".localized
        }
        
        struct Stats {
            static let title = "settings.stats.title".localized
            static let totalChannels = "settings.stats.totalChannels".localized
            static let groups = "settings.stats.groups".localized
            static let favorites = "settings.stats.favorites".localized
        }
        
        struct Data {
            static let title = "settings.data.title".localized
            static let clearAll = "settings.data.clearAll".localized
            static let clearConfirmTitle = "settings.data.clearConfirm.title".localized
            static let clearConfirmMessage = "settings.data.clearConfirm.message".localized
            static let clearConfirmDelete = "settings.data.clearConfirm.delete".localized
            static let clearConfirmCancel = "settings.data.clearConfirm.cancel".localized
            static let footer = "settings.data.footer".localized
        }
        
        struct About {
            static let title = "settings.about.title".localized
            static let version = "settings.about.version".localized
            static let developer = "settings.about.developer".localized
        }
    }
    
    // Alerts
    struct Alert {
        static let success = "alert.success".localized
        static func successLoaded(_ count: Int) -> String { "alert.success.loaded".localized(count) }
        static let ok = "alert.ok".localized
    }
    
    // General
    struct General {
        static let group = "general.group".localized
    }
}
