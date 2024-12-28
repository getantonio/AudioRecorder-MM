import SwiftUI

struct RecordingSettingsView: View {
    @ObservedObject var viewModel: AudioRecorderViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recording quality")) {
                    Picker("Channel", selection: .constant("Stereo")) {
                        Text("Mono").tag("Mono")
                        Text("Stereo").tag("Stereo")
                    }
                    
                    Picker("Sample Rate", selection: .constant("44.1 kHz")) {
                        Text("16 kHz").tag("16 kHz")
                        Text("24 kHz").tag("24 kHz")
                        Text("44.1 kHz").tag("44.1 kHz")
                        Text("48 kHz").tag("48 kHz")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

#if DEBUG
struct RecordingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingSettingsView(viewModel: AudioRecorderViewModel(
            recordingManager: RecordingManager(),
            visualizerViewModel: AudioVisualizerViewModel()
        ))
    }
}
#endif 