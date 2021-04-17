//
//  Cell.swift
//  Stargazers
//
//  Created by Matteo Matassoni on 15/04/2021.
//

import UIKit

class Cell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView? {
        didSet {
            imageView?.image = nil
        }
    }

    @IBOutlet var textLabel: UILabel? {
        didSet {
            textLabel?.text = nil
        }
    }
    @IBOutlet var detailTextLabel: UILabel? {
        didSet {
            detailTextLabel?.text = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
}
