import Foundation

struct Channel: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var streamURL: String
    var logoURL: String?
    var group: String
    var epgID: String?
    var order: Int
    
    init(id: String = UUID().uuidString, name: String, streamURL: String, logoURL: String? = nil, group: String = "Genel", epgID: String? = nil, order: Int = 0) {
        self.id = id
        self.name = name
        self.streamURL = streamURL
        self.logoURL = logoURL
        self.group = group
        self.epgID = epgID
        self.order = order
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChannelGroup: Identifiable {
    let id: String
    let name: String
    var channels: [Channel]
    
    init(name: String, channels: [Channel] = []) {
        self.id = name
        self.name = name
        self.channels = channels
    }
}
