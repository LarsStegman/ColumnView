//
//  ColumnViewController.swift
//  ColumnView
//
//  A container view which contains multiple child views as columns. Child view controllers can specify their
//  preferences via the `Sizable` protocol.
//
//  Created by Lars Stegman on 10-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import UIKit
import Foundation

open class ColumnViewController: UIViewController, UIScrollViewDelegate {

    public var delegate: ColumnViewControllerDelegate?
    var columnView: ColumnScrollView! {
        return view as? ColumnScrollView
    }

    /// The columns managed by this ColumnViewController
    public var columnViewControllers: [UIViewController] {
        return childViewControllers
    }

    // MARK: - Column creation/removal


    /// Adds a column to the column view controller. If the view controller is already in the view controller hierarchy,
    /// it will not be added again. Be sure to set the preferred content size.
    ///
    /// - Parameters:
    ///   - vc: The vc to add
    ///   - animated: Animate adding the view
    public func add(column vc: UIViewController, animated: Bool, focus: Bool = false,
                    sender: Any? = nil) {
        guard !childViewControllers.contains(vc) else {
            return
        }
        vc.willMove(toParentViewController: self)
        addChildViewController(vc)
        vc.loadViewIfNeeded()
        updateTraitCollection(forChildViewController: vc)

        let animationDirection = delegate?.columnViewController(columnViewController: self,
                                                                directionForTransitionFromViewController: nil,
                                                                to: vc) ?? .left
        let transitionContext = ColumnTransitioningContext(container: self.columnView.contentView,
                                                           from: nil, to: vc, animated: animated,
                                                           direction: animationDirection, completion: { (finished) in
            vc.didMove(toParentViewController: self)
            if focus {
                print("Scroll to view")
            }
        })

        let animator = delegate?.columnViewController(columnViewController: self,
                                                      animationControllerForTransitionFrom: nil,
                                                      to: vc) ?? FlyInOutAnimatedTransitioning()
        animator.animateTransition(using: transitionContext!)
    }

    /// Removes a column from the view controller.
    ///
    /// - Parameters:
    ///   - vc: The vc to remove
    ///   - animated: Animate removing the view
    public func remove(column vc: UIViewController, animated: Bool) {
        guard childViewControllers.contains(vc) else {
            return
        }
        
        vc.willMove(toParentViewController: nil)
        columnView.remove(column: vc.view)

        vc.removeFromParentViewController()
    }

    open func canPerform(action: Selector, sender: Any?) -> Bool {
        switch action {
        case #selector(show(_:sender:)): return true
        default: return false
        }
    }

    open override func show(_ vc: UIViewController, sender: Any?) {
        self.add(column: vc, animated: true, focus: true, sender: sender)
    }

    // MARK: - View management

    open override func loadView() {
        view = ColumnScrollView()
        columnView.delegate = self
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    /// Notifies the column view controller that a child view has updated its preferred horizontal size class. 
    ///
    /// - Important: Update the vc's `preferredContentSize` before calling this method, if you want to change its width.
    ///
    /// - Parameter vc: The vc
    public func preferredHorizontalSizeClassDidChange(forChildViewController vc: UIViewController) {
        guard childViewControllers.contains(vc) else {
            return
        }

        updateTraitCollection(forChildViewController: vc)
        vc.view.setNeedsLayout()
    }

    // MARK: - Child view trait collection management.

    /// Updates the trait collection for a child view controller
    ///
    /// - Parameter vc: The view controller to update
    private func updateTraitCollection(forChildViewController vc: UIViewController) {
        guard let preferredHorizontalSizeClass = vc.preferredHorizontalSizeClass else {
            setOverrideTraitCollection(traitCollection, forChildViewController: vc)
            return
        }

        let childHorizontalSizeClass: UIUserInterfaceSizeClass

        switch (traitCollection.horizontalSizeClass, preferredHorizontalSizeClass) {
        case (.compact, .regular): childHorizontalSizeClass = .compact
        default: childHorizontalSizeClass = preferredHorizontalSizeClass
        }

        let collection = UITraitCollection(horizontalSizeClass: childHorizontalSizeClass)
        setOverrideTraitCollection(UITraitCollection(traitsFrom: [self.traitCollection, collection]),
                                   forChildViewController: vc)
    }

    // MARK: - Column snapping

    private var lastDraggingDirection: Direction?

    // Calculates the new content offset. If the targetContentOffset is bigger of equal to the contentSize width minus 
    // the frame width, the new offset will not be altered, since this means that the last pane is made visible 
    // entirely.
    // In all other cases the new offset will be a column edge. If the targetContentOffset is bigger than half of the 
    // first visible column, the offset will be set to the right edge, else it will be set to the left edge.
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        lastDraggingDirection = velocity.x > 0 ? Direction.right : .left
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToColumnEdge()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToColumnEdge()
    }

    @IBInspectable var percentageBeforeSnap: CGFloat = 0.2

    private func scrollToColumnEdge() {
        guard columnView.contentSize.width > columnView.frame.width,
            let direction = lastDraggingDirection else {
            lastDraggingDirection = nil
            return
        }

        switch direction {
        case .left:
            guard let viewToSnap = columnView.columnAtLeftFrameEdge() else {
                break
            }

            if viewToSnap.frame.minX + viewToSnap.frame.width * (1 - percentageBeforeSnap) >=
                columnView.contentOffset.x {
                columnView.setContentOffset(viewToSnap.frame.origin, animated: true)
            } else {
                columnView.setContentOffset(viewToSnap.frame.topRight, animated: true)
            }
        case .right:
            guard let viewToSnap = columnView.columnAtRightFrameEdge() else {
                break
            }
            
            if columnView.contentOffset.x +
                (columnView.frame.width - percentageBeforeSnap * viewToSnap.frame.width) > viewToSnap.frame.minX {
                let xOffset = viewToSnap.frame.minX - (columnView.frame.width - viewToSnap.frame.width)
                columnView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
            } else {
                let xOffset = viewToSnap.frame.minX - columnView.frame.width
                columnView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
            }
        default: break
        }

        lastDraggingDirection = nil
    }
}

// Adds default implementations for SizableViewController
extension UIViewController: SizableViewController {
    public var columnViewController: ColumnViewController? {
        return parent as? ColumnViewController ?? parent?.columnViewController
    }

    public var preferredHorizontalSizeClass: UIUserInterfaceSizeClass? {
        return nil
    }
}


