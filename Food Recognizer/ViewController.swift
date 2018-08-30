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

    @IBOutlet weak var imageView: UIImageView!

    let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        return imagePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed.")
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            guard let results = request.results as? [VNClassificationObservation] else  {
                fatalError("Model failed to process image")
            }

            if let firstResults = results.first,
                firstResults.identifier.contains("hotdog") {
                self?.title = "HotDog!"
            } else {
                self?.title = "Not HotDog!"
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print(error)
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
                fatalError("Image is not picked or could not convert UIImage into CIImage")
        }
        
        detect(image: ciImage)
        imageView.image = userPickedImage
    }
}

extension ViewController: UINavigationControllerDelegate {

}
