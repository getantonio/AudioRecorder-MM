import Foundation

class RecordingManager: ObservableObject {
    @Published private(set) var recordings: [Recording] = []
    
    init() {
        loadRecordings()
    }
    
    func loadRecordings() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL,
                                                             includingPropertiesForKeys: nil)
            recordings = fileURLs
                .filter { $0.pathExtension == "m4a" }
                .map { Recording(url: $0) }
                .sorted { $0.date > $1.date }
        } catch {
            print("Failed to load recordings: \(error.localizedDescription)")
        }
    }
    
    func deleteRecordings(at offsets: IndexSet) {
        let recordingsToDelete = offsets.map { recordings[$0] }
        
        for recording in recordingsToDelete {
            do {
                try FileManager.default.removeItem(at: recording.url)
                if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
                    recordings.remove(at: index)
                }
            } catch {
                print("Failed to delete recording: \(error.localizedDescription)")
            }
        }
    }
} 