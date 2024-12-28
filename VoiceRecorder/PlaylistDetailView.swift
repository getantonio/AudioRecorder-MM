import SwiftUI
import AVFoundation

struct PlaylistDetailView: View {
    let playlist: Playlist
    let playlistManager: PlaylistManager
    @State private var showingDeletePlaylistAlert = false
    @State private var showingAddRecordingsSheet = false
    @State private var currentlyPlaying: Recording?
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        List {
            if playlist.recordings.isEmpty {
                Text("No recordings in this playlist")
                    .foregroundColor(.secondary)
            } else {
                ForEach(playlist.recordings) { recording in
                    RecordingRow(recording: recording)
                        .contextMenu {
                            Button("Remove from Playlist", role: .destructive) {
                                playlistManager.removeRecording(recording, from: playlist.id)
                            }
                            Button("Move to...") {
                                // Show move to playlist picker
                            }
                        }
                }
            }
        }
        .navigationTitle(playlist.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddRecordingsSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive, action: { showingDeletePlaylistAlert = true }) {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Playlist", isPresented: $showingDeletePlaylistAlert) {
            Button("Delete", role: .destructive) {
                playlistManager.deletePlaylist(playlist.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this playlist? The recordings will not be deleted.")
        }
        .sheet(isPresented: $showingAddRecordingsSheet) {
            NavigationView {
                RecordingPickerView(playlist: playlist, playlistManager: playlistManager)
            }
        }
    }
}

// New view for picking recordings to add to playlist
struct RecordingPickerView: View {
    let playlist: Playlist
    let playlistManager: PlaylistManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(RecordingManager.shared.recordings) { recording in
                Button(action: {
                    playlistManager.addRecording(recording, to: playlist.id)
                    dismiss()
                }) {
                    HStack {
                        RecordingRow(recording: recording)
                        Spacer()
                        if playlist.recordings.contains(where: { $0.id == recording.id }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Add Recordings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
} 