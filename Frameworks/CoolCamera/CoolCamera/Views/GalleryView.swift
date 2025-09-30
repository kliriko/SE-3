//
//  GalleryView.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import SwiftUI
import AVKit

struct GalleryView: View {
    @ObservedObject var cameraVm: CameraViewModel
    @StateObject private var galleryVm: GalleryViewModel = GalleryViewModel()
    @EnvironmentObject private var cameraManager: CameraManager
    @State private var isShowingMedia: Bool = false

    init(_ vm: CameraViewModel) {
        cameraVm = vm
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(galleryVm.items) { item in
                        ZStack {
                            if let image = item.thumbnail {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            } else {
                                Color.gray
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                            }

                            if item.isVideo {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .shadow(radius: 4)
                            }
                        }
                        .cornerRadius(8)
                        .onTapGesture {
                            galleryVm.selectedItem = item
                            isShowingMedia = true
                        }
                    }
                }
                .padding(8)
            }
            .navigationDestination(isPresented: $isShowingMedia) {
                FullScreenMediaView(galleryVm: galleryVm, items: galleryVm.items)
            }
        }
        .onAppear {
            galleryVm.fetchGallery()
        }
        .navigationTitle("Gallery")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    cameraVm.showGalleryView = false
                    cameraManager.startSession()
                }) {
                    Image(systemName: "arrow.left")
                }
            }
        }
    }
}
