import SwiftUI
import AVFoundation

struct RecordingsListView: View {
    @ObservedObject var recordingManager: RecordingManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedRecording: Recording?
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var recordingToDelete: Recording?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordingManager.recordings) { recording in
                    RecordingRow(recording: recording)
                        .onTapGesture {
                            if !isEditing {
                                selectedRecording = recording
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                recordingToDelete = recording
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: recordingManager.deleteRecordings)
            }
            .navigationTitle("Recordings")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #else
                ToolbarItem {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
                ToolbarItem {
                    Button("Close") {
                        dismiss()
                    }
                }
                #endif
            }
            .listStyle(.inset)
            .alert("Delete Recording", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let recording = recordingToDelete,
                       let index = recordingManager.recordings.firstIndex(where: { $0.id == recording.id }) {
                        recordingManager.deleteRecordings(at: IndexSet([index]))
                    }
                }
            } message: {
                Text("Are you sure you want to delete this recording? This action cannot be undone.")
            }
        }
        .sheet(item: $selectedRecording) { recording in
            RecordingDetailView(recording: recording)
        }
    }
}

struct RecordingRow: View {
    let recording: Recording
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recording.name)
                .font(.headline)
            Text(recording.date.formatted())
                .font(.caption)
                .foregroundColor(.secondary)
        }
    } 
}
