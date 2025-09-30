//
//  GalleryViewModel.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import Foundation
import AppKit
import AVFoundation
import Combine

struct GalleryItem: Identifiable, Equatable {
    var id: String = UUID().uuidString
    let url: URL
    let isVideo: Bool
    let thumbnail: NSImage?

    static func == (lhs: GalleryItem, rhs: GalleryItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class GalleryViewModel: ObservableObject, MediaViewDelegate {
    @Published var items: [GalleryItem] = []
    @Published var selectedItem: GalleryItem? {
        didSet {
            print("Selected item changed to: \(selectedItem?.url.path ?? "")")
        }
    }

    func fetchGallery() {
        let tempDirectoryURL = FileManager.default.temporaryDirectory

        print("Gallery loading from temp:", tempDirectoryURL.path)

        let files = getAllFiles(at: tempDirectoryURL)

        print("Gallery directory:", tempDirectoryURL.path)
        print("Found files:", files)

        var newItems: [GalleryItem] = []
        for file in files {
            print("Checking file:", file.path, file.isImage ? "(image)" : file.isVideo ? "(video)" : "(other)")

            if file.isImage {
                if let img = NSImage(contentsOf: file) {
                    print("Loaded image thumbnail:", file.lastPathComponent)
                    newItems.append(GalleryItem(url: file, isVideo: false, thumbnail: img))
                } else {
                    print("Failed to load image thumbnail:", file.lastPathComponent)
                    newItems.append(GalleryItem(url: file, isVideo: false, thumbnail: nil))
                }
            } else if file.isVideo {
                if let thumb = generateThumbnail(for: file) {
                    print("Generated video thumbnail:", file.lastPathComponent)
                    newItems.append(GalleryItem(url: file, isVideo: true, thumbnail: thumb))
                } else {
                    print("Failed to generate video thumbnail:", file.lastPathComponent)
                    newItems.append(GalleryItem(url: file, isVideo: true, thumbnail: nil))
                }
            }
        }

        self.items = newItems
    }

    private func getAllFiles(at url: URL) -> [URL] {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            return contents.filter { !$0.hasDirectoryPath }
        } catch {
            print("Failed to fetch files: \(error)")
            return []
        }
    }

    private func generateThumbnail(for url: URL) -> NSImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)

        if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
            return NSImage(cgImage: cgImage, size: .zero)
        }
        return nil
    }

    func playNextItem(currentItem: GalleryItem) {
        guard let currentIndex = items.firstIndex(of: currentItem) else { return }
        let nextIndex = currentIndex + 1
        if nextIndex < items.count {
            selectedItem = items[nextIndex]
        }
    }

    func playPreviousItem(currentItem: GalleryItem) {
        guard let currentIndex = items.firstIndex(of: currentItem) else { return }
        let previousIndex = currentIndex - 1
        if previousIndex >= 0 {
            selectedItem = items[previousIndex]
        }
    }
}
