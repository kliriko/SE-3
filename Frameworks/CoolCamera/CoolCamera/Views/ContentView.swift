//
//  ContentView.swift
//  CoolCamera
//
//  Created by Володимир on 29.09.2025.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var vm: CameraViewModel = CameraViewModel()
    @EnvironmentObject private var cameraManager: CameraManager
    @State private var isRecording: Bool = false
    
    var body: some View {
        ZStack {
            if !vm.showGalleryView {
                cameraView
            } else {
                GalleryView(vm)
            }
        }
        .onChange(of: vm.showGalleryView) { oldValue, newValue in
            if !newValue {
                cameraManager.startSession()
            }
        }
    }
    
    private var cameraView: some View {
            NavigationStack {
                VStack (spacing: 0){
                    Text("Hi Handsome!").font(Font.largeTitle)
                    
                    if cameraManager.isSessionRunning {
                        CameraPreview(session: $cameraManager.session)
                            .frame(maxHeight: 500)
                            .scaledToFill()
                    } else {
                        Color.black
                            .frame(maxHeight: 500)
                            .overlay(
                                ProgressView("Starting camera...")
                                    .foregroundColor(.white)
                            )
                    }
                    
                    HStack {
                        Button(action: {
                            vm.showGalleryView = true
                            // stop session in background
                            DispatchQueue.main.async {
                                cameraManager.stopSession()
                            }
                        }, label: {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                        })
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button(action: {
                            cameraManager.takePicture(saveAs: String(Int.random(in: 1..<99999)))
                        }, label: {
                            Image(systemName: "camera")
                                .font(.system(size: 30))
                        })
                        .buttonStyle(.plain)
                        
                        
                        Button(action: {
                            if isRecording {
                                cameraManager.stopRecording()
                            } else {
                                cameraManager.startRecording()
                            }
                            
                            isRecording.toggle()
                        }, label: {
                            Image(systemName: isRecording ? "stop.circle.fill" : "video")
                                .font(.system(size: 30))
                                .foregroundColor(isRecording ? .red : .primary)
                        })
                        .buttonStyle(.plain)
                        
                        
                        Spacer()
                        Button(action: {
                            cameraManager.restartSession()
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 30))
                        })
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .onAppear {
                    if !cameraManager.isSessionRunning {
                        cameraManager.startSession()
                    }
                }
            }
            .padding()
            .frame(width: 800, height: 600)
            .navigationTitle("Camera")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        print("Leading button tapped")
                    }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        }
    
}
            

#Preview {
    ContentView()
        .environmentObject(CameraManager())
}
