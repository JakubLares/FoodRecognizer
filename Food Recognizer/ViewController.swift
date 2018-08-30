//
//  ViewController.swift
//  Food Recognizer
//
//  Created by Jakub Lares on 29.08.18.
//  Copyright © 2018 Jakub Lares. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var hotDogImageView: UIImageView!

    lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1920x1080
        return captureSession
    }()

    let imageOutput = AVCapturePhotoOutput()
    let sessionOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var capturing = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupCaptureSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }

    private func setupCaptureSession() {
        guard let backCamera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: backCamera) else  {
                presentError("Camera setup failed")
                return
        }

        captureSession.addInput(input)
        if captureSession.canAddOutput(imageOutput) {
            captureSession.addOutput(imageOutput)
            setupPreviewLayer()
            captureSession.startRunning()
        }
    }

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = previewLayer else { return }
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(previewLayer)
    }

    private func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            presentError("Loading CoreML Model failed")
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.processRequest(request, error)
        }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            presentError(error.localizedDescription)
        }
    }

    private func processRequest(_ request: VNRequest, _ error: Error?) {
        if let error = error {
            presentError(error.localizedDescription)
            return
        }
        guard let results = request.results as? [VNClassificationObservation] else  {
            presentError("Model failed to process image")
            return
        }

        hotDogImageView.isHidden = false
        if let firstResults = results.first,
            firstResults.identifier.contains("hotdog") {
            hotDogImageView.image = #imageLiteral(resourceName: "hotDog")
            animageHotDogImageView()
        } else {
            hotDogImageView.image = #imageLiteral(resourceName: "notHotDog")
            animageHotDogImageView()
        }
        actionButton.isEnabled = true
    }

    private func setupForCapturing(_ capturing: Bool, image: CGImage? = nil) {
        switch capturing {
        case true:
            self.capturing = true
            actionButton.setImage(#imageLiteral(resourceName: "cameraButton"), for: .normal)
            imageView.isHidden = true
            hotDogImageView.isHidden = true
        case false:
            self.capturing = false
            imageView.isHidden = false
            actionButton.setImage(#imageLiteral(resourceName: "refreshButton"), for: .normal)
            if let image = image {
                imageView.image = UIImage(cgImage: image, scale: 1, orientation: .right)
            }
        }
    }

    private func animageHotDogImageView() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hotDogImageView.transform = strongSelf.hotDogImageView.transform.scaledBy(x: 2, y: 2)
        }) { _ in
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.hotDogImageView.transform = strongSelf.hotDogImageView.transform.scaledBy(x: 0.5, y: 0.5)
            }
        }
    }

    @IBAction func actionButtoTapped() {
        if capturing {
            imageOutput.capturePhoto(with: .init(), delegate: self)
            actionButton.isEnabled = false
        } else {
            setupForCapturing(true)
        }
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        actionButton.isEnabled = true
        guard let imageData = photo.fileDataRepresentation(),
            let uiImage = UIImage(data: imageData),
            let cgImage = uiImage.cgImage else {
                presentError("Error while generating image from photo capture data.")
                actionButton.isEnabled = true
                return
        }
        setupForCapturing(false, image: cgImage)
        detect(image: CIImage(cgImage: cgImage))
    }
}
