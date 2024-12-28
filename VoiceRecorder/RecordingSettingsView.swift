import SwiftUI

struct AudioRecordingSettingsView: View {
    @ObservedObject var viewModel: AudioRecorderViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Visualization") {
                    Picker("Waveform Style", selection: $viewModel.visualizerViewModel.waveformStyle) {
                        Text("Bars").tag(WaveformStyle.bars)
                        Text("Line").tag(WaveformStyle.line)
                        Text("Mirror").tag(WaveformStyle.mirror)
                    }
                }
                
                // Add other settings here
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
struct AudioRecordingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecordingSettingsView(viewModel: AudioRecorderViewModel(
            recordingManager: RecordingManager(),
            visualizerViewModel: AudioVisualizerViewModel()
        ))
    }
}
#endif 