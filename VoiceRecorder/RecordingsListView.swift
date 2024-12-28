import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var recordingManager: RecordingManager
    @State private var isEditing = false
    @State private var selectedRecordings = Set<UUID>()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordingManager.recordings) { recording in
                    NavigationLink(destination: RecordingDetailView(recording: recording)) {
                        VStack(alignment: .leading) {
                            Text(recording.url.lastPathComponent)
                                .font(.headline)
                            
                            HStack {
                                Text(recording.date, style: .date)
                                Text(recording.date, style: .time)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = recordingManager.recordings.firstIndex(where: { $0.id == recording.id }) {
                                    recordingManager.deleteRecording(at: IndexSet([index]))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recordings")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
                
                if isEditing {
                    ToolbarItem {
                        Button(role: .destructive, action: deleteSelected) {
                            Image(systemName: "trash")
                        }
                        .disabled(selectedRecordings.isEmpty)
                    }
                }
            }
            .overlay(Group {
                if recordingManager.recordings.isEmpty {
                    ContentUnavailableView("No Recordings", 
                        systemImage: "waveform",
                        description: Text("Your recordings will appear here")
                    )
                }
            })
        }
    }
    
    private func deleteSelected() {
        let indexSet = IndexSet(recordingManager.recordings.enumerated()
            .filter { selectedRecordings.contains($0.element.id) }
            .map { $0.offset }
        )
        recordingManager.deleteRecording(at: indexSet)
        selectedRecordings.removeAll()
        isEditing = false
    }
}

#if DEBUG
struct RecordingsListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsListView(recordingManager: RecordingManager())
    }
}
#endif
