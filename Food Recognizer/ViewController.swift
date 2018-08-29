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

    @IBAction func cameraTapped() {
        present(imagePicker, animated: true, completion: nil)
    }

}

extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {

}
