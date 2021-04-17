//
//  UIViewController+ShowError.swift
//  Stargazers
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit

extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(error: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK"),
            style: .cancel,
            handler: nil
        )
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
