import SwiftUI
import AVFoundation

struct PlaylistDetailView: View {
    @ObservedObject var playlist: Playlist
    @ObservedObject var playlistManager: PlaylistManager
    @State private var currentlyPlaying: Recording?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingDeleteAlert = false
    @State private var recordingToDelete: Recording?
    
    var body: some View {
        List {
            if playlist.recordings.isEmpty {
                Text("No recordings in this playlist")
                    .foregroundColor(.secondary)
            } else {
                ForEach(playlist.recordings) { recording in
                    HStack {
                        Button(action: {
                            togglePlayback(for: recording)
                        }) {
                            Image(systemName: currentlyPlaying?.id == recording.id ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(recording.url.lastPathComponent)
                                .font(.headline)
                            Text(recording.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            recordingToDelete = recording
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle(playlist.name)
        .onDisappear {
            stopPlayback()
        }
        .alert("Remove Recording", isPresented: $showingDeleteAlert, presenting: recordingToDelete) { recording in
            Button("Remove", role: .destructive) {
                removeFromPlaylist(recording)
            }
            Button("Cancel", role: .cancel) {}
        } message: { recording in
            Text("Are you sure you want to remove '\(recording.url.lastPathComponent)' from this playlist?")
        }
    }
    
    private func togglePlayback(for recording: Recording) {
        if currentlyPlaying?.id == recording.id {
            stopPlayback()
        } else {
            startPlayback(for: recording)
        }
    }
    
    private func startPlayback(for recording: Recording) {
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.play()
            currentlyPlaying = recording
        } catch {
            print("Error playing recording: \(error)")
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentlyPlaying = nil
    }
    
    private func removeFromPlaylist(_ recording: Recording) {
        playlistManager.removeRecording(recording, from: playlist.id)
    }
} 