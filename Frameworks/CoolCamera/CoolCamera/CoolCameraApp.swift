//
//  CoolCameraApp.swift
//  CoolCamera
//
//  Created by Володимир on 29.09.2025.
//

import SwiftUI

@main
struct CoolCameraApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var cameraManager = CameraManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cameraManager)
        }
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .active:
                cameraManager.startSession()
            case .inactive, .background:
                cameraManager.stopSessionAndTearDown()
            @unknown default:
                cameraManager.stopSessionAndTearDown()
            }
        }
    }
}
