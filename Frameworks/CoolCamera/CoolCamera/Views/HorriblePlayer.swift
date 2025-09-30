//
//  HorriblePlayer.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import Foundation
import SwiftUI
import AVKit

struct VideoPlayerView: NSViewRepresentable {
    let url: URL
    @Binding var isPlaying: Bool
    @Binding var isMuted: Bool
    let onVideoEnded: () -> Void
    let onError: (Error) -> Void

    func makeNSView(context: Context) -> AVPlayerView {
        let player = AVPlayer(url: url)
        print("Initializing player with URL: \(url.path)")
        let playerView = AVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .none
        player.isMuted = isMuted

        let observer = player.currentItem?.observe(\.status, options: [.new]) { item, _ in
            if item.status == .failed, let error = item.error {
                print("Playback failed: \(error.localizedDescription)")
                onError(error)
            }
        }
        context.coordinator.observer = observer

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            print("Video ended, triggering next item")
            onVideoEnded()
        }

        if isPlaying {
            player.play()
            print("Starting playback")
        }
        return playerView
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player?.isMuted = isMuted
        if isPlaying {
            nsView.player?.play()
            print("Resuming playback")
        } else {
            nsView.player?.pause()
            print("Pausing playback")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var observer: NSKeyValueObservation?
    }

    static func dismantleNSView(_ nsView: AVPlayerView, coordinator: Coordinator) {
        nsView.player?.pause()
        NotificationCenter.default.removeObserver(nsView.player as Any)
        coordinator.observer?.invalidate()
    }
}
