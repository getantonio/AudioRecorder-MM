//
//  ContentView.swift
//  VoiceRecorder
//
//  Created by Antonio Colomba on 12/27/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var recordingManager = RecordingManager()
    @StateObject private var visualizerViewModel = AudioVisualizerViewModel()
    @StateObject private var viewModel: AudioRecorderViewModel
    @State private var showingRecordings = false
    @State private var showingSettings = false
    
    init() {
        let manager = RecordingManager()
        let visualizer = AudioVisualizerViewModel()
        _recordingManager = StateObject(wrappedValue: manager)
        _visualizerViewModel = StateObject(wrappedValue: visualizer)
        _viewModel = StateObject(wrappedValue: AudioRecorderViewModel(
            recordingManager: manager,
            visualizerViewModel: visualizer
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Visualization
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                    
                    AudioVisualizerView(
                        viewModel: visualizerViewModel,
                        isRecording: viewModel.isRecording
                    )
                }
                .padding()
                
                // Recording info
                HStack(spacing: 40) {
                    VStack {
                        Text(String(format: "%02d:%02d", Int(viewModel.recordingTime) / 60, Int(viewModel.recordingTime) % 60))
                            .font(.system(.title2, design: .monospaced))
                        Text(viewModel.fileSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("Stereo")
                        Text(viewModel.sampleRate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Controls
                HStack(spacing: 40) {
                    Button(action: {
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                        } else {
                            viewModel.startRecording()
                        }
                    }) {
                        Image(systemName: viewModel.isRecording ? "stop.fill" : "record.circle")
                            .font(.system(size: 44))
                            .foregroundColor(viewModel.isRecording ? .red : .blue)
                            .frame(width: 60, height: 60)
                    }
                    
                    Button(action: {
                        viewModel.pauseRecording()
                    }) {
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Audio Recorder")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingRecordings = true }) {
                        Image(systemName: "list.bullet")
                    }
                }
                #else
                ToolbarItem {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem {
                    Button(action: { showingRecordings = true }) {
                        Image(systemName: "list.bullet")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingRecordings) {
                RecordingsListView(recordingManager: recordingManager)
            }
            .sheet(isPresented: $showingSettings) {
                RecordingSettingsView(viewModel: viewModel)
            }
        }
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
