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
    let isRecording: Bool
    
    var body: some View {
        GeometryReader { geometry in
            switch viewModel.waveformStyle {
            case .bars:
                // Classic bar visualization
                HStack(spacing: 4) {
                    ForEach(0..<Int(geometry.size.width / 6), id: \.self) { index in
                        let amplitude = viewModel.amplitudes[safe: index] ?? 0
                        RoundedRectangle(cornerRadius: 2)
                            .fill(barGradient)
                            .frame(width: 4, height: max(3, geometry.size.height * CGFloat(amplitude)))
                            .animation(WaveformStyle.bars.animation, value: amplitude)
                    }
                }
                .frame(maxHeight: .infinity)
                
            case .blocks:
                // Enhanced blocks visualization
                HStack(spacing: 4) {
                    ForEach(0..<Int(geometry.size.width / 12), id: \.self) { index in
                        let amplitude = (viewModel.amplitudes[safe: index] ?? 0) * 1.5 // Amplified
                        VStack(spacing: 2) {
                            ForEach(0..<Int(amplitude * 12), id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(barGradient)
                                    .frame(width: 8, height: 4)
                            }
                        }
                        .animation(WaveformStyle.blocks.animation, value: amplitude)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                
            case .wave:
                // New wave visualization (replacing circle)
                GeometryReader { geo in
                    Path { path in
                        let width = geo.size.width
                        let height = geo.size.height
                        let midHeight = height / 2
                        
                        path.move(to: CGPoint(x: 0, y: midHeight))
                        
                        for i in 0..<viewModel.amplitudes.count {
                            let x = width * CGFloat(i) / CGFloat(viewModel.amplitudes.count)
                            let amplitude = (viewModel.amplitudes[safe: i] ?? 0) * 1.5 // Amplified
                            let y = midHeight + sin(Double(i) * 0.3) * height * 0.3 * amplitude
                            
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(barGradient, lineWidth: 3)
                    .animation(WaveformStyle.wave.animation, value: viewModel.amplitudes)
                }
                
            case .spectrum:
                // Inverted spectrum analyzer
                HStack(spacing: 2) {
                    ForEach(0..<Int(geometry.size.width / 4), id: \.self) { index in
                        let amplitude = viewModel.amplitudes[safe: index] ?? 0
                        VStack(spacing: 1) {
                            ForEach((0..<15).reversed(), id: \.self) { level in
                                let isLit = CGFloat(level) / 15.0 <= amplitude
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(isLit ? spectrumColor(for: 14 - level) : Color.gray.opacity(0.3))
                                    .frame(width: 3, height: 3)
                            }
                        }
                        .animation(WaveformStyle.spectrum.animation, value: amplitude)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.15, blue: 0.25))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var barGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue,
                Color.blue.opacity(0.8),
                Color(red: 0.3, green: 0.7, blue: 1.0)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private func spectrumColor(for level: Int) -> Color {
        let progress = Double(level) / 14.0
        if progress < 0.4 {
            return .green
        } else if progress < 0.7 {
            return .yellow
        } else {
            return .red
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
} 
