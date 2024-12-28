import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var playlistManager: PlaylistManager
    @State private var showingPlaylistCreation = false
    @State private var selectedRecording: Recording?
    @State private var showingNewPlaylistSheet = false
    @State private var newPlaylistName = ""
    
    var body: some View {
        List {
            // Playlists Section
            Section(header: Text("Playlists")) {
                ForEach(playlistManager.playlists) { playlist in
                    NavigationLink {
                        PlaylistDetailView(
                            playlist: playlist,
                            playlistManager: playlistManager
                        )
                    } label: {
                        HStack {
                            Image(systemName: "music.note.list")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(playlist.name)
                                    .font(.headline)
                                Text("\(playlist.recordings.count) recordings")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            
            // Recordings Section
            Section(header: Text("Recordings")) {
                ForEach(recordingManager.recordings) { recording in
                    NavigationLink {
                        RecordingDetailView(
                            recording: recording,
                            playlistManager: playlistManager
                        )
                    } label: {
                        RecordingRow(recording: recording)
                    }
                    .contextMenu {
                        ForEach(playlistManager.playlists) { playlist in
                            Button(playlist.name) {
                                playlistManager.addRecording(recording, to: playlist.id)
                            }
                        }
                        Divider()
                        Button("New Playlist...", action: {
                            selectedRecording = recording
                            showingPlaylistCreation = true
                        })
                    }
                }
                .onDelete(perform: deleteRecordings)
            }
        }
        .navigationTitle("Recordings & Playlists")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNewPlaylistSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            #else
            ToolbarItem {
                Button(action: { showingNewPlaylistSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            #endif
        }
        .sheet(isPresented: $showingNewPlaylistSheet) {
            NavigationView {
                Form {
                    TextField("Playlist Name", text: $newPlaylistName)
                }
                .navigationTitle("New Playlist")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingNewPlaylistSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            if !newPlaylistName.isEmpty {
                                playlistManager.createPlaylist(name: newPlaylistName)
                                newPlaylistName = ""
                                showingNewPlaylistSheet = false
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingPlaylistCreation) {
            if let recording = selectedRecording {
                NavigationView {
                    PlaylistPickerView(recording: recording, playlistManager: playlistManager)
                }
            }
        }
    }
    
    private func deleteRecordings(at offsets: IndexSet) {
        recordingManager.deleteRecordings(at: offsets)
    }
}

struct RecordingRow: View {
    let recording: Recording
    
    var body: some View {
        HStack {
            Image(systemName: "waveform")
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(recording.name)
                Text(recording.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#if DEBUG
struct RecordingsListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsListView(recordingManager: RecordingManager(), playlistManager: PlaylistManager())
    }
}
#endif
