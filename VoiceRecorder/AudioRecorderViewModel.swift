import Foundation
import AVFoundation

class AudioRecorderViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var audioRecorder: AVAudioRecorder?
    @Published var recordingTime: TimeInterval = 0
    @Published var fileSize: String = "0KB"
    @Published var sampleRate: String = "44.1 kHz"
    @Published var isPaused = false
    
    private var timer: Timer?
    private let recordingManager: RecordingManager
    private let visualizerViewModel: AudioVisualizerViewModel
    
    init(recordingManager: RecordingManager, visualizerViewModel: AudioVisualizerViewModel) {
        self.recordingManager = recordingManager
        self.visualizerViewModel = visualizerViewModel
    }
    
    func startRecording() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = formatter.string(from: Date())
        let filename = "Recording-\(dateString).m4a"
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent(filename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000
        ]
        
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted else {
                    print("Microphone permission denied")
                    return
                }
            }
            
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            guard audioRecorder?.record() == true else {
                print("Failed to start recording")
                return
            }
            
            isRecording = true
            visualizerViewModel.startVisualization(for: audioRecorder)
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.recordingTime = self?.audioRecorder?.currentTime ?? 0
                self?.updateFileSize()
            }
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        // Stop visualization
        visualizerViewModel.stopVisualization()
        
        // Refresh the recordings list
        recordingManager.loadRecordings()
    }
    
    func pauseRecording() {
        if isPaused {
            audioRecorder?.record()
            visualizerViewModel.startVisualization(for: audioRecorder)
            isPaused = false
        } else {
            audioRecorder?.pause()
            visualizerViewModel.stopVisualization()
            isPaused = true
        }
    }
    
    private func updateFileSize() {
        if let url = audioRecorder?.url {
            do {
                let resources = try url.resourceValues(forKeys: [.fileSizeKey])
                if let size = resources.fileSize {
                    fileSize = "\(size/1024)KB"
                }
            } catch {
                print("Error getting file size")
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
} 