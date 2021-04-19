//
//  ContainerViewController.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit

class ContainerViewController: UIViewController {
    private var _content: UIViewController?
    var content: UIViewController? {
        get { _content }
        set { setContent(newValue, animated: false) }
    }

    func setContent(_ content: UIViewController?, animated: Bool) {
        let oldContent = _content
        _content = content

        guard isViewLoaded
        else { return }

        replaceChild(oldContent, with: content, animated: animated)

        if content != oldContent {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    init(content: UIViewController?) {
        _content = content
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(content: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        replaceChild(nil, with: content, animated: false)
    }

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        content?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        content?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        content?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        content?.endAppearanceTransition()
    }

    private func replaceChild(_ oldChild: UIViewController?,
                              with newChild: UIViewController?,
                              animated: Bool) {
        let duration: TimeInterval
        let options: UIView.AnimationOptions

        if animated {
            duration = 0.3
            options = [.transitionCrossDissolve, .beginFromCurrentState]
        } else {
            duration = 0
            options = [.beginFromCurrentState]
        }

        switch (oldChild, newChild) {
        case let (old?, new?):
            transition(from: old,
                       to: new,
                       in: view,
                       animated: animated,
                       duration: duration,
                       options: options,
                       completion: nil)
        case (nil, let new?):
            transition(to: new,
                       in: view,
                       animated: animated,
                       duration: duration,
                       options: options,
                       completion: nil)
        case (let old?, nil):
            transition(from: old,
                       in: view,
                       animated: animated,
                       duration: duration,
                       options: options,
                       completion: nil)
        case (nil, nil):
            return
        }
    }

    private func transition(to: UIViewController,
                            in container: UIView,
                            animated: Bool,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions,
                            completion: ((Bool) -> Void)?) {
        addChild(to)
        to.beginAppearanceTransition(true, animated: animated)
        to.view.alpha = 0

        container.embedSubview(to.view)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: options,
                       animations: {
                           to.view.alpha = 1
                       }, completion: { finished in
                           if finished {
                               to.didMove(toParent: self)
                               to.endAppearanceTransition()
                           }

                           completion?(finished)
                       })
    }

    private func transition(from: UIViewController,
                            in _: UIView,
                            animated: Bool,
                            duration: TimeInterval,
                            options _: UIView.AnimationOptions,
                            completion: ((Bool) -> Void)?) {
        // animate out the "from" view
        // remove it

        from.willMove(toParent: nil)
        from.beginAppearanceTransition(false, animated: animated)

        UIView.animate(withDuration: duration, animations: {
            from.view.alpha = 0
        }, completion: { finished in
            from.view.removeFromSuperview()
            from.endAppearanceTransition()
            from.removeFromParent()

            completion?(finished)
        })
    }

    private func transition(from: UIViewController,
                            to: UIViewController,
                            in container: UIView,
                            animated: Bool,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions,
                            completion: ((Bool) -> Void)?) {
        guard from != to
        else { return }

        // animate from "from" view to "to" view

        from.willMove(toParent: nil)
        addChild(to)

        from.beginAppearanceTransition(false, animated: animated)
        to.beginAppearanceTransition(true, animated: animated)

        to.view.alpha = 0
        from.view.alpha = 1

        container.embedSubview(to.view)
        container.bringSubviewToFront(from.view)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: options,
                       animations: {
                           to.view.alpha = 1
                           from.view.alpha = 0
                       }, completion: { finished in
                           from.view.removeFromSuperview()
                           from.endAppearanceTransition()
                           from.removeFromParent()

                           if finished {
                               to.didMove(toParent: self)
                               to.endAppearanceTransition()
                           }

                           completion?(finished)
                       })
    }
}

// MARK: Status Bar

extension ContainerViewController {
    override var childForStatusBarStyle: UIViewController? {
        content
    }

    override var childForStatusBarHidden: UIViewController? {
        content
    }
}

// MARK: Home Indicator

extension ContainerViewController {
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        content
    }
}

// MARK: Screen-edge gestures

extension ContainerViewController {
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        content
    }
}
