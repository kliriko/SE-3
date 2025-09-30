//
//  GalleryItemView.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import SwiftUI
import AVKit

struct GalleryItemView: View {
    let file: URL
    
    var body: some View {
        ZStack {
            if file.isImage {
                if let nsImage = NSImage(contentsOf: file) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray
                }
            } else if file.isVideo {
                VideoThumbnailView(videoURL: file)
            } else {
                Color.black
            }
        }
        .cornerRadius(8)
    }
}

