//
//  GalleryView.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import SwiftUI
import AVFoundation

struct GalleryView: View {
    @ObservedObject var cameraVm: CameraViewModel
    @EnvironmentObject private var cameraManager: CameraManager
    
    init(_ vm: CameraViewModel) {
        cameraVm = vm
    }
    
    var body: some View {
        NavigationStack {
            Text("Test")
        }
        .navigationTitle("Gallery")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    // Go back to camera and restart session
                    cameraVm.showGalleryView = false
                    cameraManager.startSession()
                }) {
                    Image(systemName: "arrow.left")
                }
            }
        }

    }
}

#Preview {
    GalleryView(CameraViewModel())
}
