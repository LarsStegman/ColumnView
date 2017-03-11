//
//  FlyInOutAnimatedTransitioning.swift
//  ColumnView
//
//  Created by Lars Stegman on 07-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

public class FlyInOutAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    private var duration = 0.35
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated ?? true ? duration : 0
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVc = transitionContext.viewController(forKey: .to)!
        transitionContext.containerView.addSubview(toVc.view)
        let translatedOrigin = transitionContext.initialFrame(for: toVc).origin
        toVc.view.transform = CGAffineTransform(translationX: translatedOrigin.x, y: translatedOrigin.y)
        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: { toVc.view.transform = CGAffineTransform.identity },
                       completion: { (finished) in transitionContext.completeTransition(finished) })
    }

    public func animationEnded(_ transitionCompleted: Bool) {

    }
}
