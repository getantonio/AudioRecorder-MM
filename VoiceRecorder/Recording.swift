import Foundation

struct Recording: Identifiable {
    let id: UUID
    let url: URL
    let name: String
    let date: Date
    
    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent
        self.date = (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()
    }
} 