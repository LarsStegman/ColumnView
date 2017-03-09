//
//  ColumnScrollView.swift
//  ColumnView
//
//  Created by Lars Stegman on 07-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import UIKit

class ColumnScrollView: UIScrollView {

    private(set) var contentView: ColumnView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("ColumnScrollView does not support initialization by coder yet")
    }

    convenience init() {
        self.init(frame: .zero)
    }

    /// Sets up the initial constraints
    private func setup() {
        decelerationRate = UIScrollViewDecelerationRateFast
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = true
        delaysContentTouches = false
        isUserInteractionEnabled = true
        contentView = ColumnView()
        translatesAutoresizingMaskIntoConstraints = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        super.addSubview(contentView)
        let constraints = [NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self,
                                              attribute: .top, multiplier: 1.0, constant: 0),
                           NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self,
                                              attribute: .leading, multiplier: 1.0, constant: 0),
                           NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: self,
                                              attribute: .height, multiplier: 1.0, constant: 0)]
        contentView.clipsToBounds = true
        self.addConstraints(constraints)
    }

    public func add(column: UIView) {
        contentView.addSubview(column)
    }

    public func remove(column: UIView) {
        guard contentView.subviews.contains(column) else {
            return
        }

        column.removeFromSuperview()
    }

    func columnAtLeftFrameEdge() -> UIView? {
        return contentView.column(at: contentOffset)?.column
    }

    func columnAtRightFrameEdge() -> UIView? {
        return contentView.column(at: contentOffset.offsetBy(dx: self.frame.width, dy: 0))?.column
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        contentSize = contentView.frame.size
    }
}
