import SwiftUI
import AVFoundation

class AudioVisualizerViewModel: ObservableObject {
    @Published var amplitudes: [CGFloat] = Array(repeating: 0, count: 100)
    @Published var waveformStyle: WaveformStyle = .bars
    private var timer: Timer?
    
    func startVisualization(for recorder: AVAudioRecorder?) {
        guard let recorder = recorder else { return }
        recorder.isMeteringEnabled = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            recorder.updateMeters()
            self?.updateAmplitudes(from: recorder)
        }
    }
    
    private func updateAmplitudes(from recorder: AVAudioRecorder) {
        amplitudes.removeFirst()
        let level = recorder.averagePower(forChannel: 0)
        let normalizedValue = normalize(level)
        amplitudes.append(normalizedValue)
    }
    
    private func normalize(_ power: Float) -> CGFloat {
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        
        // Enhanced normalization for better visual feedback
        let normalizedValue = pow((power - minDb) / (maxDb - minDb), 2)
        return CGFloat(max(0.0, min(1.0, normalizedValue))) * 0.95 + 0.05
    }
    
    func stopVisualization() {
        timer?.invalidate()
        timer = nil
        amplitudes = Array(repeating: 0, count: 100)
    }
}

struct AudioVisualizerView: View {
    @ObservedObject var viewModel: AudioVisualizerViewModel
    var isRecording: Bool
    
    var body: some View {
        Group {
            switch viewModel.waveformStyle {
            case .bars:
                barsWaveform
            case .line:
                lineWaveform
            case .mirror:
                mirrorWaveform
            }
        }
        .animation(viewModel.waveformStyle.animation, value: viewModel.amplitudes)
    }
    
    private var barsWaveform: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(viewModel.amplitudes.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 3, height: viewModel.amplitudes[index] * 100)
            }
        }
    }
    
    private var lineWaveform: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(viewModel.amplitudes.count - 1)
                
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for (index, amplitude) in viewModel.amplitudes.enumerated() {
                    let x = CGFloat(index) * step
                    let y = height / 2 - (amplitude * height / 2)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
    
    private var mirrorWaveform: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(viewModel.amplitudes.count - 1)
                
                for (index, amplitude) in viewModel.amplitudes.enumerated() {
                    let x = CGFloat(index) * step
                    let halfHeight = height / 2
                    let amplitudeHeight = amplitude * halfHeight
                    
                    // Top wave
                    path.move(to: CGPoint(x: x, y: halfHeight - amplitudeHeight))
                    path.addLine(to: CGPoint(x: x, y: halfHeight))
                    
                    // Bottom wave (mirrored)
                    path.move(to: CGPoint(x: x, y: halfHeight))
                    path.addLine(to: CGPoint(x: x, y: halfHeight + amplitudeHeight))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
} 
