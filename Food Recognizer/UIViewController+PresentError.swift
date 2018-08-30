//
//  UIViewController+PresentError.swift
//  Food Recognizer
//
//  Created by Jakub Lares on 30.08.18.
//  Copyright © 2018 Jakub Lares. All rights reserved.
//

import UIKit

extension UIViewController {

    func presentError(_ errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
