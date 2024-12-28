import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var playlistManager: PlaylistManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingPlaylistPicker = false
    @State private var selectedRecording: Recording?
    
    var body: some View {
        List {
            ForEach(recordingManager.recordings) { recording in
                RecordingRow(recording: recording, playlistManager: playlistManager)
            }
            .onDelete(perform: deleteRecordings)
        }
        .navigationTitle("Recordings")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
            #else
            ToolbarItem {
                Button("Done") {
                    dismiss()
                }
            }
            #endif
        }
    }
    
    private func deleteRecordings(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordingManager.recordings[index]
            do {
                try FileManager.default.removeItem(at: recording.url)
                recordingManager.recordings.remove(at: index)
            } catch {
                print("Error deleting recording: \(error)")
            }
        }
    }
}

struct RecordingRow: View {
    let recording: Recording
    @ObservedObject var playlistManager: PlaylistManager
    @State private var showingPlaylistPicker = false
    
    var body: some View {
        NavigationLink(destination: RecordingDetailView(recording: recording)) {
            VStack(alignment: .leading) {
                Text(recording.url.lastPathComponent)
                    .font(.headline)
                Text(recording.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .contextMenu {
            Button {
                showingPlaylistPicker = true
            } label: {
                Label("Add to Playlist", systemImage: "plus.circle")
            }
            
            Button(role: .destructive) {
                do {
                    try FileManager.default.removeItem(at: recording.url)
                    if let index = playlistManager.playlists.firstIndex(where: { $0.recordings.contains { $0.id == recording.id } }) {
                        playlistManager.playlists[index].recordings.removeAll { $0.id == recording.id }
                    }
                } catch {
                    print("Error deleting recording: \(error)")
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingPlaylistPicker) {
            PlaylistPickerView(recording: recording, playlistManager: playlistManager)
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
