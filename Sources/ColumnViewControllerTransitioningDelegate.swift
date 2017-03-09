//
//  ColumnViewControllerTransitioningDelegate.swift
//  ColumnView
//
//  Created by Lars Stegman on 06-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

class ColumnViewControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FlyInOutAnimatedTransitioning()
    }
}
