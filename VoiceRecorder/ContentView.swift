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
    @StateObject private var playlistManager = PlaylistManager()
    @StateObject private var visualizerViewModel = AudioVisualizerViewModel()
    @StateObject private var viewModel: AudioRecorderViewModel
    @State private var showingSettings = false
    @State private var selectedVisualizerStyle = 2 // Default to waveform style
    @State private var showingRecordingsList = false
    
    init() {
        let manager = RecordingManager()
        let visualizer = AudioVisualizerViewModel()
        _recordingManager = StateObject(wrappedValue: manager)
        _visualizerViewModel = StateObject(wrappedValue: visualizer)
        _viewModel = StateObject(wrappedValue: AudioRecorderViewModel(
            recordingManager: manager,
            visualizerViewModel: visualizer
        ))
        _playlistManager = StateObject(wrappedValue: PlaylistManager())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.1, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack {
                    // Top toolbar
                    HStack {
                        Button(action: { showingRecordingsList = true }) {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                        }
                        Spacer()
                        Text("Audio Recorder")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                                .font(.title2)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    // Visualizer card
                    VStack {
                        AudioVisualizerView(viewModel: visualizerViewModel, isRecording: viewModel.isRecording)
                            .frame(height: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                            )
                        
                        // Visualizer style selector
                        HStack(spacing: 20) {
                            ForEach(0..<4) { index in
                                Button(action: { selectedVisualizerStyle = index }) {
                                    Image(systemName: visualizerIcon(for: index))
                                        .font(.title2)
                                        .foregroundColor(selectedVisualizerStyle == index ? .blue : .gray)
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedVisualizerStyle == index ? 
                                                    Color.blue.opacity(0.2) : Color(red: 0.15, green: 0.15, blue: 0.25))
                                        )
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    
                    // Recording info
                    HStack(spacing: 30) {
                        VStack(alignment: .leading) {
                            Text(timeString(from: viewModel.recordingTime))
                                .font(.system(.title, design: .monospaced))
                            Text(viewModel.fileSize)
                                .font(.caption)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Stereo")
                            Text("44.1 kHz")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Text("Storage Remaining: 7.47GB")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Spacer()
                    
                    // Recording controls
                    HStack(spacing: 40) {
                        Button(action: {}) {
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color(red: 0.15, green: 0.15, blue: 0.25)))
                        }
                        
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: viewModel.isRecording ? 4 : 35)
                                        .fill(Color.red)
                                        .frame(width: viewModel.isRecording ? 20 : 70,
                                               height: viewModel.isRecording ? 20 : 70)
                                )
                        }
                        
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.pauseRecording()
                            }
                        }) {
                            Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color(red: 0.15, green: 0.15, blue: 0.25)))
                        }
                        .disabled(!viewModel.isRecording)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            RecordingSettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingRecordingsList) {
            NavigationView {
                RecordingsListView(recordingManager: recordingManager, playlistManager: playlistManager)
            }
        }
    }
    
    private func visualizerIcon(for index: Int) -> String {
        switch index {
        case 0: return "waveform.path.ecg"
        case 1: return "chart.bar.fill"
        case 2: return "waveform"
        case 3: return "chart.xyaxis.line"
        default: return "waveform"
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
