//
//  VideoThumbnailView.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL
    @State private var thumbnail: NSImage? = nil
    
    var body: some View {
        ZStack {
            if let image = thumbnail {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.black
            }
            
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .shadow(radius: 4)
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
        
        DispatchQueue.global().async {
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                let nsImage = NSImage(cgImage: cgImage, size: .zero)
                DispatchQueue.main.async {
                    thumbnail = nsImage
                }
            }
        }
    }
}
