import Foundation

struct Recording: Identifiable, Codable {
    private(set) var id: UUID
    let url: URL
    let date: Date
    var playlistIds: Set<UUID> = []
    
    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.date = (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, url, date, playlistIds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.url = try container.decode(URL.self, forKey: .url)
        self.date = try container.decode(Date.self, forKey: .date)
        self.playlistIds = try container.decode(Set<UUID>.self, forKey: .playlistIds)
    }
} 