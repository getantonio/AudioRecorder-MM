import SwiftUI
import AVFoundation

struct AudioTrimView: View {
    let recording: Recording
    @State private var startTime: TimeInterval = 0
    @State private var endTime: TimeInterval
    @State private var duration: TimeInterval = 0
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var audioPlayer: AVAudioPlayer?
    
    init(recording: Recording) {
        self.recording = recording
        _endTime = State(initialValue: 0)
        
        // Initialize audio player and get duration
        if let player = try? AVAudioPlayer(contentsOf: recording.url) {
            self._duration = State(initialValue: player.duration)
            self._endTime = State(initialValue: player.duration)
            self.audioPlayer = player
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Waveform visualization
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                    
                    // Progress indicator
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: geometry.size.width * CGFloat(currentTime / duration))
                }
            }
            .frame(height: 100)
            .overlay(
                // Trim handles
                HStack {
                    trimHandle(position: $startTime)
                    Spacer()
                    trimHandle(position: $endTime)
                }
            )
            
            // Time indicators
            HStack {
                Text(timeString(from: startTime))
                Spacer()
                Text(timeString(from: endTime))
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Playback controls
            HStack(spacing: 40) {
                Button(action: playPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                
                Button(action: trim) {
                    Image(systemName: "scissors")
                        .font(.system(size: 44))
                }
            }
        }
        .padding()
        .navigationTitle("Edit Recording")
        .onDisappear {
            stopPlayback()
        }
    }
    
    private func trimHandle(position: Binding<TimeInterval>) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.blue)
            .frame(width: 4, height: 100)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = position.wrappedValue + Double(value.translation.width / 200)
                        position.wrappedValue = max(0, min(duration, newPosition))
                    }
            )
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func playPause() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        guard let player = audioPlayer else { return }
        player.currentTime = startTime
        player.play()
        isPlaying = true
        
        // Start timer to update currentTime
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if player.currentTime >= endTime {
                stopPlayback()
                timer.invalidate()
            } else {
                currentTime = player.currentTime
            }
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = startTime
    }
    
    private func trim() {
        // Implement audio trimming logic
        // This will involve:
        // 1. Creating a new audio file
        // 2. Copying the selected portion
        // 3. Saving the trimmed file
        print("Trimming from \(startTime) to \(endTime)")
    }
} 