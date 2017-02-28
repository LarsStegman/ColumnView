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

    var columnView: ColumnView! {
        return view as? ColumnView
    }

    private var columnWidthConstraints = [NSLayoutConstraint]()

    // MARK: - Column creation/removal

    /// Adds a column to the column view controller. If the view controller is already in the view controller hierarchy,
    /// it will not be added again. Be sure to set the preferred content size.
    ///
    /// - Parameters:
    ///   - vc: The vc to add
    ///   - animated: Animate adding the view
    public func addColumn(vc: UIViewController, animated: Bool, focus: Bool = false) {
        guard !childViewControllers.contains(vc) else {
            return
        }
        addChildViewController(vc)
        columnView.add(column: vc.view, animated: animated, focus: true)
        let widthConstraint = NSLayoutConstraint(item: vc.view, attribute: .width, relatedBy: .equal,
                                                 toItem: columnView, attribute: .width, multiplier: 1, constant: 0)
        columnWidthConstraints.append(widthConstraint)

        updateWidth(forChildViewController: vc)
        updateTraitCollection(forChildViewController: vc)
        vc.didMove(toParentViewController: self)
    }

    /// Removes a column from the view controller.
    ///
    /// - Parameters:
    ///   - vc: The vc to remove
    ///   - animated: Animate removing the view
    public func removeColumn(vc: UIViewController, animated: Bool) {
        guard let constraintIndex = childViewControllers.index(of: vc) else {
            return
        }
        
        vc.willMove(toParentViewController: nil)
        columnView.remove(column: vc.view, animated: animated)
        columnWidthConstraints.remove(at: constraintIndex)

        vc.removeFromParentViewController()
    }

    public func canPerform(action: Selector, sender: Any?) -> Bool {
        switch action {
        case #selector(show(_:sender:)): return true
        default: return false
        }
    }

    public override func show(_ vc: UIViewController, sender: Any?) {
        self.addColumn(vc: vc, animated: true, focus: true)
    }

    // MARK: - View management

    public override func loadView() {
        view = ColumnView()
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

        updateWidth(forChildViewController: vc)
        updateTraitCollection(forChildViewController: vc)
        vc.view.setNeedsLayout()
    }

    // MARK: - Child view width and trait collection management.

    /// Updates the width constraint based on the preferred content size.
    ///
    /// - Parameter vc: The view controller to update
    private func updateWidth(forChildViewController vc: UIViewController) {
        guard let index = childViewControllers.index(of: vc) else {
            return
        }
        let constraint = columnWidthConstraints[index]

        let preferredContentWidthRatio = vc.preferredContentSize.width / view.frame.width
        let ratio: Double
        switch preferredContentWidthRatio {
        case 0.0..<1/5: ratio = 1/5
        case 1/5..<1/3: ratio = 1/3
        case 1/3..<1/2: ratio = 1/2
        case 1/2..<2/3: ratio = 2/3
        case 2/3..<4/5: ratio = 4/5
        default:        ratio = 1/1
        }

        columnWidthConstraints[index] = constraint.setMultiplier(multiplier: CGFloat(ratio))
    }

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
        print("Did end dragging")
        if !decelerate {
            scrollToColumnEdge()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Did end decelerating")
        scrollToColumnEdge()
    }

    var percentageBeforeSnap: CGFloat = 0.2

    private func scrollToColumnEdge() {
        guard columnView.contentSize.width > columnView.frame.width else {
            lastDraggingDirection = nil
            return
        }

        if let direction = lastDraggingDirection {
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
            }
        }

        lastDraggingDirection = nil
    }

    
}

// Adds default implementations for SizableViewController
extension UIViewController: SizableViewController {
    public var columnViewController: ColumnViewController? {
        return parent as? ColumnViewController ?? parent?.columnViewController
    }
    
    public var canOpenDetailsViewController: Bool {
        return false
    }

    public var stringForOpeningDetailsViewController: String? {
        return nil
    }

    public func openDetailsViewController() { }

    public var preferredHorizontalSizeClass: UIUserInterfaceSizeClass? {
        return nil
    }
}


