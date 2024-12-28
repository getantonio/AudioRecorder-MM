import SwiftUI
import AVFoundation

struct WaveformView: View {
    let url: URL
    @State private var samples: [Float] = []
    @State private var isLoading = true
    @State private var error: Error?
    
    var body: some View {
        GeometryReader { geometry in
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if error != nil {
                Text("Failed to load waveform")
                    .foregroundColor(.red)
            } else {
                Canvas { context, size in
                    let width = size.width
                    let height = size.height
                    let midY = height / 2
                    let sampleCount = samples.count
                    let stepWidth = width / CGFloat(sampleCount)
                    
                    // Draw waveform bars
                    for i in 0..<sampleCount {
                        let x = CGFloat(i) * stepWidth
                        let amplitude = CGFloat(samples[i])
                        let barHeight = amplitude * height / 2
                        
                        // Top bar
                        let topRect = CGRect(
                            x: x,
                            y: midY - barHeight,
                            width: stepWidth * 0.8,
                            height: barHeight
                        )
                        
                        // Bottom bar (mirrored)
                        let bottomRect = CGRect(
                            x: x,
                            y: midY,
                            width: stepWidth * 0.8,
                            height: barHeight
                        )
                        
                        context.fill(
                            Path(roundedRect: topRect, cornerRadius: 1),
                            with: .color(.blue.opacity(0.8))
                        )
                        
                        context.fill(
                            Path(roundedRect: bottomRect, cornerRadius: 1),
                            with: .color(.blue.opacity(0.8))
                        )
                    }
                }
            }
        }
        .onAppear {
            loadAudioSamples()
        }
    }
    
    private func loadAudioSamples() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let file = try AVAudioFile(forReading: url)
                let format = AVAudioFormat(standardFormatWithSampleRate: file.fileFormat.sampleRate, channels: 1)!
                let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
                try file.read(into: buf)
                
                // Get samples
                let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count: Int(buf.frameLength)))
                
                // Downsample to ~200 points for better performance
                let sampleCount = 200
                let samplesPerPoint = max(1, floatArray.count / sampleCount)
                var downsampled: [Float] = []
                
                for i in stride(from: 0, to: floatArray.count, by: samplesPerPoint) {
                    let endIndex = min(i + samplesPerPoint, floatArray.count)
                    let slice = floatArray[i..<endIndex]
                    let max = slice.map(abs).max() ?? 0
                    downsampled.append(max)
                }
                
                // Normalize
                if let maxAmplitude = downsampled.max(), maxAmplitude > 0 {
                    downsampled = downsampled.map { $0 / maxAmplitude }
                }
                
                DispatchQueue.main.async {
                    self.samples = downsampled
                    self.isLoading = false
                }
            } catch {
                print("Error loading audio samples: \(error)")
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}

#if DEBUG
struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(url: URL(fileURLWithPath: ""))
            .frame(height: 100)
            .padding()
    }
}
#endif 