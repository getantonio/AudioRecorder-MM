import SwiftUI
import AVFoundation

struct RecordingDetailView: View {
    let recording: Recording
    @Environment(\.dismiss) var dismiss
    @StateObject private var player = AudioPlayer()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(recording.name)
                    .font(.title)
                    .padding()
                
                Text(recording.date.formatted())
                    .foregroundColor(.secondary)
                
                // Playback controls
                HStack(spacing: 40) {
                    Button(action: {
                        if player.isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                    }) {
                        Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                    }
                    
                    Button(action: player.stop) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 44))
                    }
                }
                
                // Progress
                Text(player.timeString)
                    .font(.caption)
                    .monospacedDigit()
            }
            .padding()
            .navigationTitle("Recording")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        player.stop()
                        dismiss()
                    }
                }
                #else
                ToolbarItem {
                    Button("Done") {
                        player.stop()
                        dismiss()
                    }
                }
                #endif
            }
        }
        .onAppear {
            player.setup(url: recording.url)
        }
        .onDisappear {
            player.stop()
        }
    }
}

class AudioPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    var timeString: String {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func setup(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to create audio player: \(error.localizedDescription)")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.currentTime = self?.audioPlayer?.currentTime ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
} 