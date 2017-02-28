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
open class ColumnView: UIScrollView {

    public var dissmissAnimationDuration = 0.5

    private var contentView: UIView!
    private(set) var columnViews = [UIView]()
    private var columnConstraints = [[NSLayoutConstraint]]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("ColumnView does not support initialization by coder yet")
    }

    convenience init() {
        self.init(frame: .zero)
    }

    /// Sets up the initial constraints
    private func setup() {
        decelerationRate = UIScrollViewDecelerationRateFast
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = true
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        super.addSubview(contentView)
        let constraints = [NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self,
                                              attribute: .top, multiplier: 1.0, constant: 0),
                           NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self,
                                              attribute: .leading, multiplier: 1.0, constant: 0),
                           NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: self,
                                              attribute: .width, multiplier: 1.0, constant: 0),
                           NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: self,
                                              attribute: .height, multiplier: 1.0, constant: 0)]
        
        self.addConstraints(constraints)
    }


    /// If a view is added, it will be sized across the whole height of the column view. The width is set by looking at
    /// the `intrinsicContentSize` attribute. The view will be positioned on the right of the already present views.
    ///
    /// - Parameters:
    ///   - view: The view to add
    ///   - animated: Whether to add the view animated
    ///   - focus: Whether the new view should be scrolled into view.
    public func add(column view: UIView, animated: Bool, focus: Bool) {
        let viewToAlignLeftEdgeTo = columnViews.last ?? contentView!
        let edgeAttribute: NSLayoutAttribute = viewToAlignLeftEdgeTo == contentView ? .left : .right
        let cornerCoordinate = viewToAlignLeftEdgeTo == contentView ?
            viewToAlignLeftEdgeTo.frame.origin : viewToAlignLeftEdgeTo.frame.topRight
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)

        let initialOffset = frame.width - cornerCoordinate.x + contentOffset.x

        let verticalConstraints =
            [NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top,
                                multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: contentView,
                                attribute: .bottom, multiplier: 1.0, constant: 0)]
        let horizontalConstraint =
             NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: viewToAlignLeftEdgeTo,
                                attribute: edgeAttribute, multiplier: 1.0, constant: initialOffset)
        columnViews.append(view)
        columnConstraints.append(verticalConstraints + [horizontalConstraint])

        contentView.addConstraints(verticalConstraints + [horizontalConstraint])
        setNeedsUpdateConstraints()
        contentView.layoutSubviews()
        horizontalConstraint.constant = 0
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: animated && initialOffset > 0 ? 0.2 : 0,
                       delay: dissmissAnimationDuration, options: [.curveEaseOut],
                       animations: {
            self.contentView.layoutSubviews()
        }, completion: { (_) in
            if focus && self.contentSize.width > self.frame.width {
                let xOffset = view.frame.minX - (self.frame.width - view.frame.width)
                self.setContentOffset(CGPoint(x: xOffset, y: 0), animated: animated)
            }
        })
    }

    /// Removes a column.
    ///
    /// - Parameters:
    ///   - view: The view to remove.
    ///   - animated: Whether to animate the removal.
    public func remove(column view: UIView, animated: Bool) {
        layoutIfNeeded()
        guard let index = columnViews.index(of: view) else {
            return
        }
        let removedViewWidth = view.frame.width
        columnViews.remove(at: index)
        let viewConstraints = columnConstraints.remove(at: index)

        UIView.animate(withDuration: animated ? dissmissAnimationDuration : 0, delay: 0,
                       options: [.curveEaseInOut], animations: {
            view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            view.alpha = 0
        }, completion: { (_) in
            view.removeConstraints(viewConstraints)
            view.removeFromSuperview()
        })

        guard columnViews.count > 0 && index < columnViews.count else {
            return
        }

        let nextView = columnViews[index]
        let previousView = index == 0 ? contentView! : columnViews[index - 1]
        let edgeAttribute: NSLayoutAttribute = previousView == contentView ? .left : .right
        let horizontalPositionConstraint = NSLayoutConstraint(item: nextView, attribute: .left, relatedBy: .equal,
                                                              toItem: previousView, attribute: edgeAttribute,
                                                              multiplier: 1.0, constant: removedViewWidth)
        contentView.addConstraint(horizontalPositionConstraint)
        setNeedsUpdateConstraints()
        contentView.layoutSubviews()

        horizontalPositionConstraint.constant = 0
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: animated ? 0.2 : 0, delay: animated ? 0.8 * dissmissAnimationDuration : 0,
                       options: [.curveEaseOut],
                       animations: {
            self.contentView.layoutSubviews()
        })
    }

    /// Returns the view column at a certain point. If no column is present, nil will be returned.
    ///
    /// - Parameter point: The point in the scroll view contentSize system.
    /// - Parameter dir: Whether to return the view to the left or right of this view.
    /// - Returns: The frame
    ///
    /// - Complexity: O(n)
    func column(at point: CGPoint, to dir: Direction? = nil) -> (atPoint: UIView, next: UIView?)? {
        for index in columnViews.indices {
            let column = columnViews[index]
            if column.frame.contains(point) {
                if let d = dir {
                    switch d {
                    case .left:
                        return (column, index > 0 ? columnViews[index - 1] : nil)
                    case .right:
                        return (column, index < columnViews.count - 1 ? columnViews[index + 1] : nil)
                    }
                } else {
                    return (column, nil)
                }
            }
        }

        return nil
    }

    func columnAtLeftFrameEdge() -> UIView? {
        for index in columnViews.indices {
            let column = columnViews[index]
            if column.frame.contains(contentOffset) {
                return column
            }
        }
        
        return nil
    }

    func columnAtRightFrameEdge() -> UIView? {
        let rightEdgePoint = CGPoint(x: contentOffset.x + frame.width, y: 0)
        for index in columnViews.indices {
            let column = columnViews[index]
            if column.frame.contains(rightEdgePoint) {
                return column
            }
        }

        return nil
    }


    /// The width of the contentView
    /// 
    /// Note: Make sure all subviews are laid out.
    var width: CGFloat {
        return columnViews.reduce(0, { return $0 + $1.frame.width })
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let width = self.width
        contentSize = CGSize(width: width, height: frame.height)
    }
}

extension CGRect {
    var topRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.minY)
    }
}
