import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var recordingManager: RecordingManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordingManager.recordings) { recording in
                    NavigationLink(destination: RecordingDetailView(recording: recording)) {
                        VStack(alignment: .leading) {
                            Text(recording.url.lastPathComponent)
                            Text(recording.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: recordingManager.deleteRecording)
            }
            .navigationTitle("Recordings")
        }
    }
}
