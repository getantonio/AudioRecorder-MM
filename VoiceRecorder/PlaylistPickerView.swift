import SwiftUI

struct PlaylistPickerView: View {
    let recording: Recording
    @ObservedObject var playlistManager: PlaylistManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingCreatePlaylist = false
    @State private var newPlaylistName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(playlistManager.playlists) { playlist in
                    Button(action: {
                        playlistManager.addRecording(recording, to: playlist.id)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(playlist.name)
                                    .font(.headline)
                                Text("\(playlist.recordings.count) recordings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if playlist.recordings.contains(where: { $0.id == recording.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to Playlist")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCreatePlaylist = true }) {
                        Image(systemName: "plus")
                    }
                }
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
                                let playlist = Playlist(name: newPlaylistName)
                                playlistManager.createPlaylist(name: newPlaylistName)
                                playlistManager.addRecording(recording, to: playlist.id)
                                newPlaylistName = ""
                                showingCreatePlaylist = false
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
} 