import SwiftUI

struct PlaylistView: View {
    @ObservedObject var playlistManager: PlaylistManager
    @State private var showingCreatePlaylist = false
    @State private var newPlaylistName = ""
    
    var body: some View {
        List {
            ForEach(playlistManager.playlists) { playlist in
                NavigationLink(destination: PlaylistDetailView(playlist: playlist, playlistManager: playlistManager)) {
                    VStack(alignment: .leading) {
                        Text(playlist.name)
                            .font(.headline)
                        Text("\(playlist.recordings.count) recordings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .contextMenu {
                    Button(role: .destructive) {
                        playlistManager.deletePlaylist(playlist.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Playlists")
        .toolbar {
            Button(action: { showingCreatePlaylist = true }) {
                Label("New Playlist", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingCreatePlaylist) {
            NavigationView {
                Form {
                    TextField("Playlist Name", text: $newPlaylistName)
                }
                .navigationTitle("New Playlist")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingCreatePlaylist = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            if !newPlaylistName.isEmpty {
                                playlistManager.createPlaylist(name: newPlaylistName)
                                newPlaylistName = ""
                                showingCreatePlaylist = false
                            }
                        }
                    }
                }
            }
        }
    }
} 