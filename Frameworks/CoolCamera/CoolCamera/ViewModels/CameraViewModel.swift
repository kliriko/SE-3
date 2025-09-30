//
//  CameraViewModel.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import Foundation
import Combine
import SwiftUI

class CameraViewModel: ObservableObject {
    @EnvironmentObject var cameraManager: CameraManager
    @Published var showGalleryView = false
}

extension URL {
    var isImage: Bool {
        ["jpg", "jpeg", "png"].contains(self.pathExtension.lowercased())
    }
    
    var isVideo: Bool {
        ["mov", "mp4"].contains(self.pathExtension.lowercased())
    }
}
