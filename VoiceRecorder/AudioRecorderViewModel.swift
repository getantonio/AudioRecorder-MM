import Foundation
import AVFoundation

class AudioRecorderViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordingTime: TimeInterval = 0
    @Published var fileSize: String = "0 KB"
    @Published var sampleRate: String = "44.1 kHz"
    
    private var recordingManager: RecordingManager
    var visualizerViewModel: AudioVisualizerViewModel
    private var timer: Timer?
    
    init(recordingManager: RecordingManager, visualizerViewModel: AudioVisualizerViewModel) {
        self.recordingManager = recordingManager
        self.visualizerViewModel = visualizerViewModel
        recordingManager.setVisualizerViewModel(visualizerViewModel)
    }
    
    func startRecording() {
        print("ViewModel: Starting recording")
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let audioFilename = documentsPath.appendingPathComponent("Recording-\(timestamp).m4a")
        
        recordingManager.startRecording(url: audioFilename)
        isRecording = true
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
            self?.updateFileSize(url: audioFilename)
        }
    }
    
    func stopRecording() {
        print("ViewModel: Stopping recording")
        recordingManager.stopRecording()
        isRecording = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        recordingTime = 0
    }
    
    func pauseRecording() {
        print("ViewModel: Toggling pause state")
        recordingManager.pauseRecording()
        isPaused.toggle()
    }
    
    private func updateFileSize(url: URL) {
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            if let size = resources.fileSize {
                fileSize = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
            }
        } catch {
            print("Error getting file size: \(error)")
        }
    }
} 