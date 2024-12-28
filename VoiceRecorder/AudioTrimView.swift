import SwiftUI
import AVFoundation

struct AudioTrimView: View {
    let recording: Recording
    @State private var startTime: TimeInterval = 0
    @State private var endTime: TimeInterval
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isDraggingSlider = false
    @State private var selectedTool: EditTool = .trim
    
    enum EditTool {
        case trim, removeMid, duplicate
    }
    
    init(recording: Recording) {
        self.recording = recording
        _endTime = State(initialValue: 0)
        
        // Initialize audio player and get duration
        if let player = try? AVAudioPlayer(contentsOf: recording.url) {
            _duration = State(initialValue: player.duration)
            _endTime = State(initialValue: player.duration)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Waveform and timeline
            ZStack(alignment: .top) {
                // Timeline markers
                TimelineView(duration: duration)
                    .frame(height: 30)
                
                // Waveform
                WaveformView(url: recording.url)
                    .frame(height: 120)
                    .padding(.top, 30)
                
                // Selection overlay
                SelectionOverlay(startTime: $startTime, endTime: $endTime, currentTime: $currentTime, duration: duration)
            }
            .padding()
            #if os(macOS)
            .background(Color(NSColor.windowBackgroundColor))
            #else
            .background(Color(.systemGray6))
            #endif
            
            // Edit tools
            HStack(spacing: 30) {
                EditToolButton(tool: .trim, selectedTool: $selectedTool)
                EditToolButton(tool: .removeMid, selectedTool: $selectedTool)
                EditToolButton(tool: .duplicate, selectedTool: $selectedTool)
            }
            .padding()
            
            // Playback controls
            VStack(spacing: 20) {
                // Time slider
                HStack {
                    Text(timeString(from: currentTime))
                    Slider(value: $currentTime, in: 0...duration) { isDragging in
                        isDraggingSlider = isDragging
                        if !isDragging {
                            audioPlayer?.currentTime = currentTime
                        }
                    }
                    Text(timeString(from: duration))
                }
                .padding(.horizontal)
                
                // Transport controls
                HStack(spacing: 40) {
                    Button(action: skipBackward) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    
                    Button(action: togglePlayback) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                    }
                    
                    Button(action: skipForward) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(recording.url.lastPathComponent)
        .toolbar {
            ToolbarItem {
                Button("Save") {
                    saveEdit()
                }
            }
        }
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            if audioPlayer == nil {
                audioPlayer = try? AVAudioPlayer(contentsOf: recording.url)
                audioPlayer?.currentTime = currentTime
            }
            audioPlayer?.play()
        }
        isPlaying = !isPlaying
    }
    
    private func skipForward() {
        currentTime = min(duration, currentTime + 5)
        audioPlayer?.currentTime = currentTime
    }
    
    private func skipBackward() {
        currentTime = max(0, currentTime - 5)
        audioPlayer?.currentTime = currentTime
    }
    
    private func saveEdit() {
        // Implement audio trimming/editing logic
    }
}

struct TimelineView: View {
    let duration: TimeInterval
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let markCount = Int(duration / 5) + 1
            
            ForEach(0..<markCount, id: \.self) { index in
                let x = width * CGFloat(index) / CGFloat(markCount - 1)
                VStack(spacing: 2) {
                    Text("\(index * 5)")
                        .font(.caption2)
                    Rectangle()
                        .frame(width: 1, height: 8)
                }
                .position(x: x, y: 15)
            }
        }
    }
}

struct SelectionOverlay: View {
    @Binding var startTime: TimeInterval
    @Binding var endTime: TimeInterval
    @Binding var currentTime: TimeInterval
    let duration: TimeInterval
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            // Selection region
            Rectangle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: width * CGFloat((endTime - startTime) / duration))
                .offset(x: width * CGFloat(startTime / duration))
            
            // Playhead
            Rectangle()
                .fill(Color.red)
                .frame(width: 2)
                .offset(x: width * CGFloat(currentTime / duration))
        }
    }
}

struct EditToolButton: View {
    let tool: AudioTrimView.EditTool
    @Binding var selectedTool: AudioTrimView.EditTool
    
    var body: some View {
        Button(action: { selectedTool = tool }) {
            VStack {
                Image(systemName: iconName)
                    .font(.title2)
                Text(toolName)
                    .font(.caption)
            }
        }
        .foregroundColor(selectedTool == tool ? .blue : .primary)
    }
    
    private var iconName: String {
        switch tool {
        case .trim: return "scissors"
        case .removeMid: return "minus.rectangle"
        case .duplicate: return "plus.rectangle.on.rectangle"
        }
    }
    
    private var toolName: String {
        switch tool {
        case .trim: return "Trim"
        case .removeMid: return "Remove Middle"
        case .duplicate: return "Duplicate"
        }
    }
} 