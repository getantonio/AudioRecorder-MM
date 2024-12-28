import Foundation
import AVFoundation
#if os(macOS)
import AppKit
#endif

class RecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published private(set) var permissionGranted = false
    @Published private(set) var permissionStatus = "Checking..."
    private var audioRecorder: AVAudioRecorder?
    @Published var recordings: [Recording] = []
    private var visualizerViewModel: AudioVisualizerViewModel?
    private var currentRecordingURL: URL?
    
    override init() {
        super.init()
        loadRecordings()
        print("RecordingManager initialized")
        checkInitialPermissions()
    }
    
    private func checkInitialPermissions() {
        #if os(macOS)
        print("Checking initial microphone permissions...")
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        print("Current authorization status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                self.permissionGranted = true
                self.permissionStatus = "Authorized"
                print("✅ Microphone access already authorized")
            }
        case .notDetermined:
            self.permissionStatus = "Not determined"
            print("❓ Microphone access not determined")
            // Don't request permission yet, wait for user action
        case .denied:
            self.permissionStatus = "Denied"
            print("❌ Microphone access denied")
        case .restricted:
            self.permissionStatus = "Restricted"
            print("⚠️ Microphone access restricted")
        @unknown default:
            self.permissionStatus = "Unknown"
            print("❌ Unknown microphone access status")
        }
        #endif
    }
    
    func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        #if os(macOS)
        print("Requesting microphone access...")
        
        // Simple direct request
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                print("Permission response received: \(granted)")
                self?.permissionGranted = granted
                self?.permissionStatus = granted ? "Granted" : "Denied"
                
                if !granted {
                    self?.showSettingsAlert()
                }
                
                completion(granted)
            }
        }
        #endif
    }
    
    func startRecording(url: URL) {
        print("Starting recording at URL: \(url)")
        currentRecordingURL = url
        
        #if os(macOS)
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        print("Current auth status before recording: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("Already authorized, starting recording...")
            initiateRecording(url: url)
        case .notDetermined:
            print("Permission not determined, requesting access...")
            requestMicrophoneAccess { [weak self] granted in
                if granted {
                    self?.initiateRecording(url: url)
                } else {
                    self?.showSettingsAlert()
                }
            }
        case .denied, .restricted:
            print("Permission denied or restricted, showing settings alert...")
            showSettingsAlert()
        @unknown default:
            print("Unknown permission status")
            showSettingsAlert()
        }
        #endif
    }
    
    func requestPermissions() {
        #if os(macOS)
        // Request permissions only when needed
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            DispatchQueue.main.async {
                self.permissionGranted = true
                print("Microphone access already authorized")
            }
        case .notDetermined:
            print("Requesting microphone access...")
            // Force the system permission dialog to appear
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    print("Microphone access granted: \(granted)")
                    if granted {
                        // If permission was just granted, try recording again
                        self?.startRecording(url: self?.currentRecordingURL ?? URL(fileURLWithPath: ""))
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.permissionGranted = false
                print("Microphone access denied")
                // Show the settings alert
                let alert = NSAlert()
                alert.messageText = "Microphone Access Required"
                alert.informativeText = "Please enable microphone access in System Settings to record audio."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Cancel")
                
                if alert.runModal() == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        @unknown default:
            DispatchQueue.main.async {
                self.permissionGranted = false
                print("Unknown microphone access status")
            }
        }
        #else
        setupAudioSession()
        #endif
    }
    
    #if os(iOS)
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session category set")
            
            audioSession.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    print("Recording permission granted: \(granted)")
                }
            }
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    #endif
    
    func setVisualizerViewModel(_ viewModel: AudioVisualizerViewModel) {
        self.visualizerViewModel = viewModel
    }
    
    private func initiateRecording(url: URL) {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000
        ]
        
        do {
            // Stop any existing recording
            audioRecorder?.stop()
            audioRecorder = nil
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            guard let recorder = audioRecorder else {
                print("❌ Failed to create audio recorder")
                return
            }
            
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            
            if !recorder.prepareToRecord() {
                print("❌ Failed to prepare recorder")
                return
            }
            
            if recorder.record() {
                print("✅ Recording started successfully")
                visualizerViewModel?.startVisualization(for: recorder)
            } else {
                print("❌ Failed to start recording")
            }
        } catch {
            print("❌ Recording failed with error: \(error.localizedDescription)")
        }
    }
    
    private func showSettingsAlert() {
        #if os(macOS)
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Microphone Access Required"
            alert.informativeText = """
                To enable microphone access:
                1. Click 'Open Settings'
                2. Go to Privacy & Security > Microphone
                3. Find and enable this app
                """
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Cancel")
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
            }
        }
        #endif
    }
    
    func stopRecording() {
        print("Stopping recording")
        visualizerViewModel?.stopVisualization()
        
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        #endif
        
        audioRecorder?.stop()
        audioRecorder = nil
        loadRecordings()
    }
    
    func pauseRecording() {
        if audioRecorder?.isRecording == true {
            print("Pausing recording")
            audioRecorder?.pause()
            visualizerViewModel?.stopVisualization()
        } else {
            print("Resuming recording")
            audioRecorder?.record()
            visualizerViewModel?.startVisualization(for: audioRecorder)
        }
    }
    
    // AVAudioRecorderDelegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Recording finished, success: \(flag)")
        if flag {
            loadRecordings()
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Recording encode error: \(error.localizedDescription)")
        }
    }
    
    // Add delete functionality
    func deleteRecordings(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            do {
                try FileManager.default.removeItem(at: recording.url)
                recordings.remove(at: index)
            } catch {
                print("Error deleting recording: \(error)")
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
                .map { url in 
                    Recording(
                        url: url,
                        date: (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()
                    )
                }
                .sorted { $0.date > $1.date }
        } catch {
            print("Failed to load recordings: \(error.localizedDescription)")
        }
    }
} 