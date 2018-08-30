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

class ViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!

    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        return imagePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
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

        if let firstResults = results.first,
            firstResults.identifier.contains("hotdog") {
            title = "HotDog!"
        } else {
            title = "Not HotDog!"
        }
    }

    @IBAction func cameraTapped() {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let ciImage = CIImage(image: userPickedImage) else {
                presentError("Image is not picked or could not convert UIImage into CIImage")
                return
        }
        
        detect(image: ciImage)
        imageView.image = userPickedImage
    }
}

extension ViewController: UINavigationControllerDelegate {
}
