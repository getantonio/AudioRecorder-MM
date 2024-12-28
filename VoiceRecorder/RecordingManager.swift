import Foundation
import AVFoundation

class RecordingManager: NSObject, ObservableObject {
    @Published private(set) var permissionGranted = false
    private var audioRecorder: AVAudioRecorder?
    @Published var recordings: [Recording] = []
    private var visualizerViewModel: AudioVisualizerViewModel?
    
    override init() {
        super.init()
        loadRecordings()
        
        #if os(iOS)
        // Request permission immediately
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                print("Recording permission granted: \(granted)")
            }
        }
        #else
        // On macOS, set permission granted to true
        permissionGranted = true
        #endif
    }
    
    func setVisualizerViewModel(_ viewModel: AudioVisualizerViewModel) {
        self.visualizerViewModel = viewModel
    }
    
    func startRecording(url: URL) {
        #if os(iOS)
        guard permissionGranted else {
            print("Microphone permission not granted")
            return
        }
        #endif
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000
        ]
        
        do {
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            #endif
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() == true {
                print("Recording started successfully")
                visualizerViewModel?.startVisualization(for: audioRecorder)
            } else {
                print("Failed to start recording")
            }
        } catch {
            print("Recording failed: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        visualizerViewModel?.stopVisualization()
        audioRecorder?.stop()
        audioRecorder = nil
        loadRecordings()
    }
    
    func pauseRecording() {
        if audioRecorder?.isRecording == true {
            audioRecorder?.pause()
            visualizerViewModel?.stopVisualization()
        } else {
            audioRecorder?.record()
            visualizerViewModel?.startVisualization(for: audioRecorder)
        }
    }
    
    // Add delete functionality
    func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            do {
                try FileManager.default.removeItem(at: recording.url)
                recordings.remove(at: index)
            } catch {
                print("Error deleting recording: \(error.localizedDescription)")
            }
        }
    }
    
    func loadRecordings() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL,
                                                             includingPropertiesForKeys: nil)
            recordings = fileURLs
                .filter { $0.pathExtension == "m4a" }
                .map { Recording(url: $0) }
                .sorted { $0.date > $1.date }
        } catch {
            print("Failed to load recordings: \(error.localizedDescription)")
        }
    }
} 