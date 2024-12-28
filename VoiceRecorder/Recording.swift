import Foundation

struct Recording: Identifiable, Codable {
    let id: UUID
    let url: URL
    let date: Date
    
    var name: String {
        url.lastPathComponent
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    init(id: UUID = UUID(), url: URL, date: Date = Date()) {
        self.id = id
        self.url = url
        self.date = date
    }
} 