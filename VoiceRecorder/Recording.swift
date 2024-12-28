import Foundation

struct Recording: Identifiable {
    let id = UUID()
    let url: URL
    let date: Date
    
    init(url: URL) {
        self.url = url
        self.date = (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()
    }
} 