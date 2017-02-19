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

class ColumnViewController: UIViewController, UIScrollViewDelegate {

    var columnView: ColumnView! {
        return view as? ColumnView
    }

    private var columnWidthConstraints = [NSLayoutConstraint]()

    /// Adds a column to the column view controller. If the view controller is already in the view controller hierarchy,
    /// it will not be added again. Be sure to set the preferred content size.
    ///
    /// - Parameters:
    ///   - vc: The vc to add
    ///   - animated: Animate adding the view
    func addColumn(vc: UIViewController, animated: Bool, focus: Bool = false) {
        guard !childViewControllers.contains(vc) else {
            return
        }
        addChildViewController(vc)
        columnView.add(column: vc.view, animated: animated, focus: focus)
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
    func removeColumn(vc: UIViewController, animated: Bool) {
        guard let constraintIndex = childViewControllers.index(of: vc) else {
            return
        }
        
        vc.willMove(toParentViewController: nil)
        columnView.remove(column: vc.view, animated: animated)
        columnWidthConstraints.remove(at: constraintIndex)

        vc.removeFromParentViewController()
    }

    override func loadView() {
        view = ColumnView()
        columnView.delegate = self
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    /// Notifies the column view controller that a child view has updated its preferred horizontal size class. 
    ///
    /// - Important: Update the vc's `preferredContentSize` before calling this method, if you want to change its width.
    ///
    /// - Parameter vc: The vc
    func preferredHorizontalSizeClassDidChange(forChildViewController vc: UIViewController) {
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
        case 0.0..<0.2:   ratio = 1/5
        case 0.2..<(1/3): ratio = 1/3
        case (1/3)..<0.5: ratio = 1/2
        case 0.5..<(2/3): ratio = 2/3
        case (2/3)..<0.8: ratio = 4/5
        default:          ratio = 1/1
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

    private var nextOffset: CGPoint?

    // Calculates the new content offset. If the targetContentOffset is bigger of equal to the contentSize width minus 
    // the frame width, the new offset will not be altered, since this means that the last pane is made visible 
    // entirely.
    // In all other cases the new offset will be a column edge. If the targetContentOffset is bigger than half of the 
    // first visible column, the offset will be set to the right edge, else it will be set to the left edge.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset: CGPoint = targetContentOffset.pointee
        guard offset.x < columnView.contentSize.width - columnView.frame.width else {
            nextOffset = nil
            return
        }

        if let targetRect = columnView.columnFrame(for: offset) {
            if offset.x >= targetRect.midX {
                nextOffset = CGPoint(x: targetRect.maxX, y: 0)
            } else {
                nextOffset = CGPoint(x: targetRect.minX, y: 0)
            }
        } else {
            nextOffset = nil
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToColumnEdge()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToColumnEdge()
    }

    private func scrollToColumnEdge() {
        if let offset = nextOffset {
            columnView.setContentOffset(offset, animated: true)
        }
    }
}

// Adds default implementations for SizableViewController
extension UIViewController: SizableViewController {
    var columnViewController: ColumnViewController? {
        return parent as? ColumnViewController ?? parent?.columnViewController
    }

    func willPersist() { }

    func didPersist() { }

    func willDesist() { }

    func didDesist() { }

    var canOpenDetailsViewController: Bool {
        return false
    }

    var stringForOpeningDetailsViewController: String? {
        return nil
    }

    func openDetailsViewController() { }

    var preferredHorizontalSizeClass: UIUserInterfaceSizeClass? {
        return nil
    }
}

