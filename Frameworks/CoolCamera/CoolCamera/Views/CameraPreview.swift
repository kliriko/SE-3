//
//  CameraView.swift
//  CoolCamera
//
//  Created by Володимир on 30.09.2025.
//

import SwiftUI
import AVFoundation

final class PreviewNSView: NSView {
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            wantsLayer = true
            layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
            if let pl = previewLayer {
                pl.frame = bounds
                pl.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
                layer?.addSublayer(pl)
            }
        }
    }

    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }
    
    deinit {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
}

struct CameraPreview: NSViewRepresentable {
    @Binding var session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        let view = PreviewNSView(frame: .zero)
        view.wantsLayer = true

        DispatchQueue.main.async {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
            view.previewLayer = previewLayer
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let pv = nsView as? PreviewNSView {
            if pv.previewLayer?.session !== session {
                DispatchQueue.main.async {
                    if pv.previewLayer == nil {
                        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                        previewLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
                        pv.previewLayer = previewLayer
                    } else {
                        pv.previewLayer?.session = session
                    }
                }
            }
        }
    }
    
    static func dismantleNSView(_ nsView: NSView, coordinator: ()) {
        if let pv = nsView as? PreviewNSView {
            pv.previewLayer?.removeFromSuperlayer()
            pv.previewLayer = nil
        }
    }
}
