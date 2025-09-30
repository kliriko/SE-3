//
//  CameraPreview.swift
//  CoolCamera
//
//  Created by Володимир on 29.09.2025.
//

import Foundation
import AppKit
import AVFoundation
import SwiftUI
import Combine

class CameraManager: ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var photoOutput: AVCapturePhotoOutput!
    private var videoDevice: AVCaptureDevice!
    private var videoInput: AVCaptureDeviceInput!
    private var photoCaptureDelegate: CaptureDelegate?
    private var videoCaptureDelegate: CaptureDelegate?
    private var movieOutput: AVCaptureMovieFileOutput!

    init() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.setupSession()
            } else {
                print("Camera access not granted.")
            }
        }
    }

    private func setupSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.videoDevice = AVCaptureDevice.default(for: .video)
          
            do {
                self.videoInput = try AVCaptureDeviceInput(device: self.videoDevice)
            } catch {
                print("Failed to create video input:", error)
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(self.videoInput) {
                self.session.addInput(self.videoInput)
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
            
            self.movieOutput = AVCaptureMovieFileOutput()
            if self.session.canAddOutput(self.movieOutput) {
                self.session.addOutput(self.movieOutput)
            }

            self.session.commitConfiguration()
        }
    }
    
    func takePicture(saveAs fileName: String) {
        sessionQueue.async {
            guard let output = self.photoOutput else { return }
            let delegate = CaptureDelegate()
            self.photoCaptureDelegate = delegate
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isHighResolutionPhotoEnabled = true
            output.capturePhoto(with: photoSettings, delegate: delegate)
        }
    }

    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }

    func stopSessionAndTearDown() {
        sessionQueue.async {
            if let movieOutput = self.movieOutput, movieOutput.isRecording {
                movieOutput.stopRecording()
            }
            
            if self.session.isRunning {
                self.session.stopRunning()
            }
            
            self.session.beginConfiguration()
            for output in self.session.outputs {
                self.session.removeOutput(output)
            }
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.isSessionRunning = false
            }
        }
    }
    
    func restartSession() {
        stopSessionAndTearDown()
        sessionQueue.asyncAfter(deadline: .now() + 0.5) {
            self.setupSession()
            self.startSession()
        }
    }
    
    func startRecording() {
        sessionQueue.async {
            guard let movieOutput = self.movieOutput else { return }
            if !movieOutput.isRecording {
                let outputURL = self.tempFileURL()
                let delegate = CaptureDelegate()
                self.videoCaptureDelegate = delegate
                movieOutput.startRecording(to: outputURL, recordingDelegate: delegate)
                print("Started recording to \(outputURL.path)")
            }
        }
    }

    func stopRecording() {
        sessionQueue.async {
            guard let movieOutput = self.movieOutput else { return }
            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }
        }
    }

    private func tempFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "CoolVideo_\(formatter.string(from: Date())).mov"
        return tempDir.appendingPathComponent(filename)
    }
}

class CaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    var onVideoRecordingFinished: ((URL) -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        guard let data = photo.fileDataRepresentation(), let image = NSImage(data: data) else {
            print("Could not convert photo data to NSImage")
            return
        }
        
        savePhotoData(data)
    }
    
    private func savePhotoData(_ data: Data) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "CoolPhoto_\(formatter.string(from: Date())).jpg"
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            print("Photo saved to:", fileURL.path)
        } catch {
            print("Error saving photo:", error.localizedDescription)
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
        } else {
            print("Video recording finished: \(outputFileURL.path)")
            onVideoRecordingFinished?(outputFileURL)
        }
    }
}
