//
//  UIAlertController+Error.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit

extension UIAlertController {
    convenience init(
        error: Error,
        preferredStyle: UIAlertController.Style
    ) {
        let title: String?
        let message: String?
        if let localizedError = error as? LocalizedError {
            title = localizedError.errorDescription
            message = [
                localizedError.failureReason,
                localizedError.recoverySuggestion
            ]
            .compactMap { $0 }
            .joined(separator: "\n\n")
        } else {
            title = error.localizedDescription
            message = nil
        }

        self.init(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
    }
}
