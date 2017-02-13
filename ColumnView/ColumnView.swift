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
class ColumnView: UIScrollView {

    private var contentView: UIView!
    private var columnViews = [UIView]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("ColumnView does not support initialization by coder yet")
    }

    convenience init() {
        self.init(frame: .zero)
    }

    /// Sets up the initial constraints
    private func setup() {
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
    /// - Parameter view: The subview to add
    func add(column view: UIView) {
        let viewToAlignLeftEdgeTo = columnViews.last ?? contentView
        let edgeAttribute: NSLayoutAttribute = viewToAlignLeftEdgeTo == contentView ? .left : .right

        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        columnViews.append(view)
        let constraints = [NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: contentView,
                                              attribute: .top, multiplier: 1.0, constant: 0),
                           NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: contentView,
                                              attribute: .bottom, multiplier: 1.0, constant: 0),
                           NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                              toItem: viewToAlignLeftEdgeTo, attribute: edgeAttribute,
                                              multiplier: 1.0, constant: 0)]
        contentView.addConstraints(constraints)
        setNeedsLayout()
    }

    /// A list of the subview frame origins.
    /// 
    /// Note: Make sure all subviews are laid out.
    var columnAnchors: [CGPoint] {
        return columnViews.map({ return $0.frame.origin })
    }

    func targetColumnFrame(for point: CGPoint) -> CGRect? {
        for column in columnViews {
            let convertedPoint = contentView.convert(point, to: column)
            if column.point(inside: convertedPoint, with: nil) {
                return column.frame
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

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.width
        contentSize = CGSize(width: width, height: frame.height)
    }
}

extension UIView: SizableView {
    var preferredHorizontalCompactContentSize: CGSize {
        return self.intrinsicContentSize
    }

    var preferredHorizontalRegularContentSize: CGSize {
        return self.intrinsicContentSize
    }

    var preferredHorizontalSizeClass: UIUserInterfaceSizeClass {
        return self.traitCollection.horizontalSizeClass
    } 
}
