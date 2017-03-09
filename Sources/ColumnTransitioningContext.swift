//
//  ColumnTransitioningContext.swift
//  ColumnView
//
//  Created by Lars Stegman on 07-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

class ColumnTransitioningContext: NSObject, UIViewControllerContextTransitioning {
    private var viewControllers: [UITransitionContextViewControllerKey: UIViewController] = [:]
    var completion: (Bool) -> Void

    private var toVc: UIViewController! {
        return self.viewControllers[.to]
    }

    private var fromVc: UIViewController! {
        return self.viewControllers[.from]
    }

    public var containerView: UIView
    public var isAnimated: Bool
    public var isInteractive: Bool = false
    public var transitionWasCancelled: Bool = false
    public var presentationStyle: UIModalPresentationStyle {
        return .custom
    }

    public var direction: Direction
    public var isAppearing: Bool

    init?(from fromVc: UIViewController, to toVc: UIViewController,
          animated: Bool, appearing: Bool, direction: Direction, completion: @escaping (Bool) -> Void) {
        guard toVc.isViewLoaded,
            let containerVc = (fromVc as? ColumnScrollViewController ?? fromVc.columnViewController) else {
            return nil
        }

        self.containerView = containerVc.columnView.contentView
        self.viewControllers[.from] = fromVc
        self.viewControllers[.to] = toVc
        self.completion = completion
        self.isAnimated = animated
        self.isAppearing = appearing
        self.direction = direction
    }

    public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return self.viewControllers[key]
    }

    public func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case UITransitionContextViewKey.from: return nil
        case UITransitionContextViewKey.to: return self.toVc.view
        default: return nil
        }
    }

    public func initialFrame(for vc: UIViewController) -> CGRect {
        let targetFrame = vc.view.frame
        if !isAppearing {
            return targetFrame
        }

        switch direction {
        case .right: return CGRect(origin: targetFrame.origin.offsetBy(dx: -targetFrame.width, dy: 0),
                                      size: targetFrame.size)
        case .left:  return CGRect(origin: containerView.frame.topRight, size: targetFrame.size)
        case .down:  return targetFrame.offsetBy(dx: 0, dy: -containerView.frame.height)
        case .up:    return targetFrame.offsetBy(dx: 0, dy: containerView.frame.height)
        }
    }

    public func finalFrame(for vc: UIViewController) -> CGRect {
        let targetFrame = vc.view.frame
        if isAppearing {
            return targetFrame
        }

        switch direction {
        case .right: return CGRect(origin: containerView.frame.topRight,
                                   size: targetFrame.size)
        case .left:  return CGRect(origin: targetFrame.origin.offsetBy(dx: -targetFrame.width, dy: 0),
                                   size: targetFrame.size)
        case .down:  return targetFrame.offsetBy(dx: 0, dy: containerView.frame.height)
        case .up:    return targetFrame.offsetBy(dx: 0, dy: -containerView.frame.height)
        }
    }

    public var targetTransform: CGAffineTransform {
        return CGAffineTransform.identity
    }

    public func completeTransition(_ didComplete: Bool) {
        transitionWasCancelled = didComplete
        completion(didComplete)
    }

    public func updateInteractiveTransition(_ percentComplete: CGFloat) { }

    public func finishInteractiveTransition() {
        transitionWasCancelled = false
    }

    public func cancelInteractiveTransition() {
        transitionWasCancelled = true
    }

    public func pauseInteractiveTransition() { }
}


