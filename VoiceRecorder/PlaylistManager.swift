import Foundation

class PlaylistManager: ObservableObject {
    @Published var playlists: [Playlist] = []
    private let playlistsKey = "SavedPlaylists"
    
    init() {
        loadPlaylists()
    }
    
    func createPlaylist(name: String) {
        let playlist = Playlist(name: name)
        playlists.append(playlist)
        savePlaylists()
    }
    
    func addRecording(_ recording: Recording, to playlistId: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[index].recordings.append(recording)
        savePlaylists()
    }
    
    func removeRecording(_ recording: Recording, from playlistId: UUID) {
        guard let playlistIndex = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[playlistIndex].recordings.removeAll { $0.id == recording.id }
        savePlaylists()
    }
    
    func deletePlaylist(_ playlistId: UUID) {
        playlists.removeAll { $0.id == playlistId }
        savePlaylists()
    }
    
    private func savePlaylists() {
        if let encoded = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(encoded, forKey: playlistsKey)
        }
    }
    
    private func loadPlaylists() {
        if let data = UserDefaults.standard.data(forKey: playlistsKey),
           let decoded = try? JSONDecoder().decode([Playlist].self, from: data) {
            playlists = decoded
        }
    }
} 