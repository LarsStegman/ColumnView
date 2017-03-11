//
//  ColumnViewControllerDelegate.swift
//  ColumnView
//
//  Created by Lars Stegman on 10-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

public protocol ColumnViewControllerDelegate {

    /// Returns the direction to animate the addition or removal of a view controller
    ///
    /// - Parameters:
    ///   - columnViewController: The column view controller
    ///   - from: The view controller that will be removed
    ///   - to: The view controller that will be added
    /// - Returns: The direction
    func columnViewController(columnViewController: ColumnViewController,
                              directionForTransitionFromViewController from: UIViewController?,
                              to: UIViewController?) -> Direction?

    /// Returns an animation controller to use for transitions
    ///
    /// - Parameters:
    ///   - columnViewController: The column view controller
    ///   - from: The view controller that will be dismissed
    ///   - to: The view controller that will be added
    /// - Returns: The animation controller
    func columnViewController(columnViewController: ColumnViewController,
                              animationControllerForTransitionFrom from: UIViewController?,
                              to: UIViewController?) -> UIViewControllerAnimatedTransitioning?
}
