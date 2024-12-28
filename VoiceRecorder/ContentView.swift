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
                        Spacer(minLength: 50)
                        
                        ZStack {
                            // Record button (centered) - 30% smaller
                            Button(action: {
                                if viewModel.isRecording {
                                    viewModel.stopRecording()
                                } else {
                                    viewModel.startRecording()
                                }
                            }) {
                                ZStack {
                                    // Background circle with bevel effect
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.blue.opacity(0.8),
                                                    Color.blue
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                                        .shadow(color: .white.opacity(0.2), radius: 4, x: -2, y: -2)
                                        .frame(width: 56, height: 56)
                                    
                                    // Microphone icon
                                    Image(systemName: "mic.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.white)
                                    
                                    // Recording indicator ring
                                    if viewModel.isRecording {
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                            .frame(width: 63, height: 63)
                                            .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                                            .opacity(viewModel.isRecording ? 1 : 0)
                                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.isRecording)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Pause button - reduced size and adjusted position
                            Button(action: viewModel.pauseRecording) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.2, blue: 0.3),
                                                Color(red: 0.15, green: 0.15, blue: 0.25)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 28, height: 28) // Reduced from 40 to 28 (30% smaller)
                                    .overlay(
                                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                            .font(.system(size: 11)) // Reduced from 16 to 11
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!viewModel.isRecording)
                            .opacity(viewModel.isRecording ? 1 : 0.5)
                            .offset(x: 52, y: 28) // Reduced offset from (75, 40) to (52, 28)
                        }
                        
                        Spacer(minLength: 50)
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
        case .dots: return "circle.grid.3x3"
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
