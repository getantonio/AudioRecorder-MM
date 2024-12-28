import Foundation

class Playlist: ObservableObject, Identifiable, Codable {
    private(set) var id: UUID
    @Published var name: String
    @Published var recordings: [Recording]
    let createdAt: Date
    
    init(name: String, recordings: [Recording] = []) {
        self.id = UUID()
        self.name = name
        self.recordings = recordings
        self.createdAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, recordings, createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.recordings = try container.decode([Recording].self, forKey: .recordings)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(recordings, forKey: .recordings)
        try container.encode(createdAt, forKey: .createdAt)
    }
} 