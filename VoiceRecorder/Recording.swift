import Foundation

struct Recording: Identifiable {
    let id: UUID
    let url: URL
    let date: Date
    
    init(url: URL) {
        self.id = UUID()
        self.url = url
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
            self.date = attributes[.creationDate] as? Date ?? Date()
        } else {
            self.date = Date()
        }
    }
} 