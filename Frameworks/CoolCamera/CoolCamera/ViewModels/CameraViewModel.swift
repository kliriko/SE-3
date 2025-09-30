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
