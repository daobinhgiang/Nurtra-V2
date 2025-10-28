//
//  CameraView.swift
//  Nurtra V2
//
//  Created by AI Assistant
//

import SwiftUI
import AVFoundation

final class CameraUIView: UIView {
    private let captureSession = AVCaptureSession()
    private let previewLayer: AVCaptureVideoPreviewLayer

    override init(frame: CGRect) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        super.init(frame: frame)
        setupSession()
        setupPreview()
    }

    required init?(coder: NSCoder) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: AVCaptureSession())
        super.init(coder: coder)
        setupSession()
        setupPreview()
    }

    private func setupSession() {
        captureSession.sessionPreset = .high

        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .front) else {
            print("Front camera not available")
            return
        }

        do {
            captureSession.beginConfiguration()
            // Remove any existing inputs to avoid duplicates on hot reloads
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            captureSession.commitConfiguration()
        } catch {
            print("Error setting up camera input: \(error)")
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    private func setupPreview() {
        previewLayer.videoGravity = .resizeAspect // no cropping; full content visible
        layer.addSublayer(previewLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the preview uses the full view size
        previewLayer.frame = bounds
    }
}

struct CameraView: UIViewRepresentable {
    func makeUIView(context: Context) -> CameraUIView {
        let view = CameraUIView(frame: .zero)
        // Rounded corners are applied by SwiftUI clipShape in CravingView
        // but ensure sublayers respect corner radius if needed:
        view.layer.masksToBounds = true
        return view
    }

    func updateUIView(_ uiView: CameraUIView, context: Context) {
        // No dynamic updates needed for now
    }
}

#Preview {
    CameraView()
        .frame(width: 300, height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 20))
}
