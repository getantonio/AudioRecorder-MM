import SwiftUI
import AVFoundation

class AudioVisualizerViewModel: ObservableObject {
    @Published var amplitudes: [CGFloat] = Array(repeating: 0, count: 30)
    private var timer: Timer?
    
    func startVisualization(for recorder: AVAudioRecorder?) {
        guard let recorder = recorder else { return }
        recorder.isMeteringEnabled = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            recorder.updateMeters()
            self?.updateAmplitudes(from: recorder)
        }
    }
    
    private func updateAmplitudes(from recorder: AVAudioRecorder) {
        // Shift existing amplitudes to the left
        amplitudes.removeFirst()
        
        // Get the current audio level and normalize it
        let level = recorder.averagePower(forChannel: 0)
        let normalizedValue = normalize(level)
        
        // Add new amplitude value
        amplitudes.append(normalizedValue)
    }
    
    private func normalize(_ power: Float) -> CGFloat {
        // Adjust these values to make the visualization more sensitive
        let minDb: Float = -60.0  // Increased sensitivity (was -50.0)
        let maxDb: Float = 0.0
        
        // Apply a non-linear scaling to make small sounds more visible
        let normalizedValue = pow((power - minDb) / (maxDb - minDb), 2)
        return CGFloat(max(0.0, min(1.0, normalizedValue))) * 0.8 + 0.2 // Add minimum height
    }
    
    func stopVisualization() {
        timer?.invalidate()
        timer = nil
        amplitudes = Array(repeating: 0, count: 30)
    }
}

struct AudioVisualizerView: View {
    @ObservedObject var viewModel: AudioVisualizerViewModel
    var isRecording: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<viewModel.amplitudes.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 8, height: viewModel.amplitudes[index] * 100)
                    .animation(.easeOut(duration: 0.05), value: viewModel.amplitudes[index])
            }
        }
    }
} 
