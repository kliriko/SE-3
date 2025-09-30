//
//  WhyDoIExitstPlayerView.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import SwiftUI
import AVKit

protocol MediaViewDelegate: AnyObject {
    func playNextItem(currentItem: GalleryItem)
    func playPreviousItem(currentItem: GalleryItem)
}

struct FullScreenMediaView: View {
    @ObservedObject var galleryVm: GalleryViewModel
    let items: [GalleryItem]
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying: Bool = true
    @State private var isMuted: Bool = false
    @State private var playbackError: String? = nil

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if let item = galleryVm.selectedItem,
               item.isVideo && FileManager.default.isReadableFile(atPath: item.url.path) && playbackError == nil {
                VideoPlayerView(
                    url: item.url,
                    isPlaying: $isPlaying,
                    isMuted: $isMuted,
                    onVideoEnded: {
                        galleryVm.playNextItem(currentItem: item)
                    },
                    onError: { error in
                        playbackError = error.localizedDescription
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            } else if let item = galleryVm.selectedItem, !item.isVideo {
                if let image = item.thumbnail {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                } else {
                    Color.gray
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else if let error = playbackError {
                Text("Playback failed: \(error)")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Media file not accessible")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack {
                Spacer()
                HStack(spacing: 20) {
                    if let item = galleryVm.selectedItem, item.isVideo {
                        Button(action: { isPlaying.toggle() }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                    Button(action: {
                        if let item = galleryVm.selectedItem {
                            galleryVm.playPreviousItem(currentItem: item)
                        }
                    }) {
                        Image(systemName: "backward.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        if let item = galleryVm.selectedItem {
                            galleryVm.playNextItem(currentItem: item)
                        }
                    }) {
                        Image(systemName: "forward.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    if let item = galleryVm.selectedItem, item.isVideo {
                        Button(action: { isMuted.toggle() }) {
                            Image(systemName: isMuted ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            }

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .padding()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("Playing media: \(galleryVm.selectedItem?.url.path ?? ""), isVideo: \(galleryVm.selectedItem?.isVideo ?? false)")
        }
    }
}
