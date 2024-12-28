import SwiftUI
import AVKit

struct RecordingDetailView: View {
    let recording: Recording
    let playlistManager: PlaylistManager
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text(recording.url.lastPathComponent)
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text(recording.date.formatted())
                .foregroundColor(.secondary)
            
            // Playback controls
            HStack(spacing: 40) {
                Button(action: {
                    if isPlaying {
                        audioPlayer?.pause()
                    } else {
                        if audioPlayer == nil {
                            setupAudioPlayer()
                        }
                        audioPlayer?.play()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    audioPlayer?.stop()
                    audioPlayer?.currentTime = 0
                    isPlaying = false
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.red)
                }
            }
            
            // Time display
            HStack {
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(duration))
            }
            .font(.system(.caption, design: .monospaced))
            .padding(.horizontal)
            
            // Progress bar
            ProgressView(value: currentTime, total: duration)
                .padding(.horizontal)
        }
        .padding()
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }
    
    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            
            // Setup timer to update current time
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let player = audioPlayer {
                    currentTime = player.currentTime
                    if !player.isPlaying {
                        isPlaying = false
                    }
                }
            }
        } catch {
            print("Failed to initialize audio player: \(error.localizedDescription)")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 