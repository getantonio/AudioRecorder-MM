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
        let currentPlaylist = playlists[index]
        let newPlaylist = Playlist(
            name: currentPlaylist.name,
            recordings: currentPlaylist.recordings + [recording]
        )
        playlists[index] = newPlaylist
        savePlaylists()
    }
    
    func removeRecording(_ recording: Recording, from playlistId: UUID) {
        if let index = playlists.firstIndex(where: { $0.id == playlistId }) {
            let currentPlaylist = playlists[index]
            let filteredRecordings = currentPlaylist.recordings.filter { $0.id != recording.id }
            let newPlaylist = Playlist(name: currentPlaylist.name, recordings: filteredRecordings)
            playlists[index] = newPlaylist
            savePlaylists()
        }
    }
    
    func deletePlaylist(_ playlistId: UUID) {
        playlists.removeAll { $0.id == playlistId }
        savePlaylists()
    }
    
    func moveRecording(_ recording: Recording, from sourceId: UUID, to destinationId: UUID) {
        removeRecording(recording, from: sourceId)
        addRecording(recording, to: destinationId)
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