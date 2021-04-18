//
//  UIView+Subviews.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit

extension UIViewController {
    func embedChild(
        _ newChild: UIViewController,
        in container: UIView? = nil
    ) {
        // if the view controller is already a child of something else, remove it
        if let oldParent = newChild.parent, oldParent != self {
            if shouldAutomaticallyForwardAppearanceMethods {
                newChild.beginAppearanceTransition(false, animated: false)
            }
            newChild.willMove(toParent: nil)
            newChild.removeFromParent()

            if newChild.viewIfLoaded?.superview != nil {
                newChild.viewIfLoaded?.removeFromSuperview()
            }

            if shouldAutomaticallyForwardAppearanceMethods {
                newChild.endAppearanceTransition()
            }
        }

        var targetContainer = container ?? view!
        if !targetContainer.isContainedWithin(view) {
            targetContainer = view
        }

        // add the view controller as a child
        if newChild.parent != self {
            if shouldAutomaticallyForwardAppearanceMethods {
                newChild.beginAppearanceTransition(true, animated: false)
            }
            addChild(newChild)
            targetContainer.embedSubview(newChild.view)
            if shouldAutomaticallyForwardAppearanceMethods {
                newChild.endAppearanceTransition()
            }
            newChild.didMove(toParent: self)
        } else {
            // the viewcontroller is already a child
            // make sure it's in the right view

            // we don't do the appearance transition stuff here,
            // because the vc is already a child, so *presumably*
            // that transition stuff has already happened
            targetContainer.embedSubview(newChild.view)
        }
    }
}
