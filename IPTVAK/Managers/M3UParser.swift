import Foundation

class M3UParser {
    
    static func parse(_ content: String) -> [Channel] {
        var channels: [Channel] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentName: String?
        var currentLogo: String?
        var currentGroup: String = L10n.General.group
        var currentEPGID: String?
        var order = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("#EXTINF:") {
                // Parse channel info
                let info = parseExtInf(trimmedLine)
                currentName = info.name
                currentLogo = info.logo
                currentGroup = info.group ?? "Genel"
                currentEPGID = info.epgID
            } else if trimmedLine.hasPrefix("http://") || trimmedLine.hasPrefix("https://") || trimmedLine.hasPrefix("rtmp://") || trimmedLine.hasPrefix("rtsp://") {
                // This is a stream URL
                if let name = currentName {
                    let channel = Channel(
                        name: name,
                        streamURL: trimmedLine,
                        logoURL: currentLogo,
                        group: currentGroup,
                        epgID: currentEPGID,
                        order: order
                    )
                    channels.append(channel)
                    order += 1
                }
                
                // Reset for next channel
                currentName = nil
                currentLogo = nil
                currentGroup = L10n.General.group
                currentEPGID = nil
            }
        }
        
        return channels
    }
    
    private static func parseExtInf(_ line: String) -> (name: String?, logo: String?, group: String?, epgID: String?) {
        var name: String?
        var logo: String?
        var group: String?
        var epgID: String?
        
        // Extract name (after the last comma)
        if let commaRange = line.range(of: ",", options: .backwards) {
            name = String(line[commaRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        
        // Extract tvg-logo
        if let logoMatch = extractAttribute(from: line, attribute: "tvg-logo") {
            logo = logoMatch
        }
        
        // Extract group-title
        if let groupMatch = extractAttribute(from: line, attribute: "group-title") {
            group = groupMatch
        }
        
        // Extract tvg-id
        if let epgMatch = extractAttribute(from: line, attribute: "tvg-id") {
            epgID = epgMatch
        }
        
        return (name, logo, group, epgID)
    }
    
    private static func extractAttribute(from line: String, attribute: String) -> String? {
        let pattern = "\(attribute)=\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, options: [], range: range) else {
            return nil
        }
        
        if let valueRange = Range(match.range(at: 1), in: line) {
            let value = String(line[valueRange])
            return value.isEmpty ? nil : value
        }
        
        return nil
    }
    
    static func parseFromURL(_ urlString: String) async throws -> [Channel] {
        guard let url = URL(string: urlString) else {
            throw M3UError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw M3UError.downloadFailed
        }
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw M3UError.invalidContent
        }
        
        return parse(content)
    }
}

enum M3UError: LocalizedError {
    case invalidURL
    case downloadFailed
    case invalidContent
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .downloadFailed:
            return "Playlist indirilemedi"
        case .invalidContent:
            return "Playlist içeriği okunamadı"
        }
    }
}
