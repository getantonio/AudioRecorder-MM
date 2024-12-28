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
    
    func stopVisualization() {
        timer?.invalidate()
        timer = nil
        amplitudes = Array(repeating: 0, count: 30)
    }
    
    private func updateAmplitudes(from recorder: AVAudioRecorder) {
        // Shift existing amplitudes to the left
        amplitudes.removeFirst()
        
        // Get the current audio level and normalize it
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        let normalizedValue = normalize(level)
        
        // Add some minimum height for visual feedback
        let minHeight: CGFloat = 0.05
        amplitudes.append(max(normalizedValue, minHeight))
    }
    
    private func normalize(_ power: Float) -> CGFloat {
        // Convert dB to a normalized value between 0 and 1
        // dB range is typically -160 to 0
        let minDb: Float = -50.0 // Increased sensitivity
        let maxDb: Float = 0.0
        
        let normalizedValue = max(0.0, min(1.0, (power - minDb) / (maxDb - minDb)))
        return CGFloat(normalizedValue)
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
