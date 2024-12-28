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
                            ForEach(WaveformStyle.allCases, id: \.self) { style in
                                Button(action: { 
                                    visualizerViewModel.waveformStyle = style
                                }) {
                                    Image(systemName: visualizerIcon(for: style))
                                        .font(.title2)
                                        .foregroundColor(visualizerViewModel.waveformStyle == style ? .blue : .gray)
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(visualizerViewModel.waveformStyle == style ? 
                                                    Color.blue.opacity(0.2) : Color(red: 0.15, green: 0.15, blue: 0.25))
                                                .shadow(radius: 0)
                                        )
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
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
                    HStack {
                        Spacer()
                        
                        // Pause button (smaller and to the left)
                        Button(action: viewModel.pauseRecording) {
                            Circle()
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                                .frame(width: 40, height: 40)  // 50% smaller
                                .overlay(
                                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                        .font(.system(size: 16))  // Smaller icon
                                        .foregroundColor(.white)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!viewModel.isRecording)
                        .opacity(viewModel.isRecording ? 1 : 0.5)
                        .offset(x: 40)  // Move closer to record button
                        
                        // Record button (centered)
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: viewModel.isRecording ? Color.red.opacity(0.5) : .clear,
                                            radius: viewModel.isRecording ? 10 : 0)
                                
                                if viewModel.isRecording {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white)
                                        .frame(width: 28, height: 28)
                                } else {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 60)
                                        .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
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
    
    private func visualizerIcon(for style: WaveformStyle) -> String {
        switch style {
        case .bars: return "waveform.path.ecg"
        case .blocks: return "square.grid.3x3.fill"
        case .wave: return "waveform"
        case .spectrum: return "chart.bar.xaxis"
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
