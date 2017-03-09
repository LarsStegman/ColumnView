//
//  ColumnView.swift
//  ColumnView
//
//  Created by Lars Stegman on 12-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

/// Maintains columns of views.
open class ColumnView: UIView {
    private var columnConstraints = [[NSLayoutAttribute: NSLayoutConstraint]]()
    private var columnWidthConstraints = [NSLayoutConstraint]()

    open override func addSubview(_ view: UIView) {
        insertSubview(view, at: subviews.count)
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        let left = subviews.count > 0 && index > 0 ? subviews[index - 1] : self
        let right = index < subviews.count ? subviews[index] : self


        let leftEdgeAttribute = left == self ? NSLayoutAttribute.leading : .trailing
        let rightEdgeAtribute = right == self ? NSLayoutAttribute.trailing : .leading

        view.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutAttribute: NSLayoutConstraint]()
        constraints[.top]       = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self,
                                                     attribute: .top, multiplier: 1.0, constant: 0)
        constraints[.bottom]    = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self,
                                                     attribute: .bottom, multiplier: 1.0, constant: 0)
        constraints[.leading]   = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: left,
                                                     attribute: leftEdgeAttribute, multiplier: 1.0, constant: 0)
        constraints[.trailing]  = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: right,
                                                     attribute: rightEdgeAtribute, multiplier: 1.0, constant: 0)
        constraints[.width]     = width(forView: view)

        if subviews.count > 0 && index > 0 {
            NSLayoutConstraint.deactivate([columnConstraints[index - 1][.trailing]!])
            columnConstraints[index - 1][.trailing] = constraints[.leading]
        }
        if subviews.count > index {
            NSLayoutConstraint.deactivate([columnConstraints[index][.leading]!])
            columnConstraints[index][.leading] = constraints[.trailing]
        }

        super.insertSubview(view, at: index)

        columnConstraints.insert(constraints, at: index)
        NSLayoutConstraint.activate(Array(constraints.values))

        setNeedsUpdateConstraints()
    }

    open override func willRemoveSubview(_ subview: UIView) {
        guard let index = subviews.index(of: subview) else {
            return
        }

        let constraints = columnConstraints[index]
        NSLayoutConstraint.deactivate(Array(constraints.values))
        guard subviews.count > 1 else { // If not, there is only one view, and we don't need to update constraints anymore.
            return
        }

        var adjacencyConstraint: NSLayoutConstraint? = nil
        if let left = constraints[.leading]?.secondItem as? UIView,
            let right = constraints[.trailing]?.secondItem as? UIView {
            let leftEdgeAttribute = left == self ? NSLayoutAttribute.leading : .trailing
            let rightEdgeAttribute = right == self ? NSLayoutAttribute.trailing : .leading
            adjacencyConstraint = NSLayoutConstraint(item: left, attribute: leftEdgeAttribute, relatedBy: .equal,
                                                         toItem: right, attribute: rightEdgeAttribute, multiplier: 1.0,
                                                         constant: 0)
        }

        guard let adjacencyConstraintV = adjacencyConstraint else {
            return
        }
        superview?.addConstraint(adjacencyConstraintV)

        if index > 0 {
            columnConstraints[index - 1][.trailing] = adjacencyConstraintV
        }

        if index < subviews.count - 1 {
            columnConstraints[index + 1][.leading] = adjacencyConstraintV
        }
    }

    /// Returns the view column at a certain point. If no column is present, nil will be returned.
    ///
    /// - Parameter point: The point this view's coordinate space.
    /// - Returns: The view at the point and its subview index
    ///
    /// - Complexity: O(n)
    func column(at point: CGPoint) -> (column: UIView, index: Int)? {
        for (index, column) in subviews.enumerated()  {
            if column.frame.contains(point) {
                return (column, index)
            }
        }

        return nil
    }

    /// Updates the width constraint based on the preferred content size.
    ///
    /// - Parameter vc: The view controller to update
    private func width(forView view: UIView) -> NSLayoutConstraint {
        let preferredContentWidthRatio = view.intrinsicContentSize.width / (superview?.bounds.width ?? 1)
        let ratio: Double
        switch preferredContentWidthRatio {
        case 0.0..<1/5: ratio = 1/5
        case 1/5..<1/3: ratio = 1/3
        case 1/3..<1/2: ratio = 1/2
        case 1/2..<2/3: ratio = 2/3
        case 2/3..<4/5: ratio = 4/5
        default:        ratio = 1/1
        }

        return NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: superview,
                                  attribute: .width, multiplier: CGFloat(ratio), constant: 0)
    }
}

extension CGRect {
    var topRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.minY)
    }
}
