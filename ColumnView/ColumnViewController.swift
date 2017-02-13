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

class ColumnViewController: UIViewController, UIScrollViewDelegate {

    var columnView: ColumnView! {
        return view as? ColumnView
    }

    func addColumn(vc: UIViewController, animated: Bool) {
        addChildViewController(vc)
        self.view.addSubview(vc.view)

        vc.didMove(toParentViewController: self)
    }

    override func loadView() {
        view = ColumnView()
        columnView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        let button = UIButton()
        button.setTitle("Hello, world!", for: .normal)
        button.backgroundColor = .green
        columnView.add(column: button)

        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ut dui. "
        label.backgroundColor = .red
        columnView.add(column: label)

        let label0 = UILabel()
        label0.text = "Lorem ipsum dolor sit  adipiscing elit. Phasellus ut dui. "
        label0.backgroundColor = .purple
        columnView.add(column: label0)

        let label1 = UILabel()
        label1.text = " amet, elit. Phasellus ut dui.Phasellus ut duiPhasellus ut duiPhasellus ut duiPhasellus ut dui "
        label1.backgroundColor = UIColor.yellow
        columnView.add(column: label1)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    private var nextOffset: CGPoint?

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset: CGPoint = targetContentOffset.pointee
        guard offset.x != columnView.contentSize.width - columnView.frame.width else {
            nextOffset = nil
            return
        }

        if let targetRect = columnView.targetColumnFrame(for: offset) {
            let leftEdge = targetRect.minX
            let rightEdge = targetRect.maxX
            if offset.x >= targetRect.midX {
                nextOffset = CGPoint(x: rightEdge, y: 0)
            } else {
                nextOffset = CGPoint(x: leftEdge, y: 0)
            }
        } else {
            nextOffset = nil
        }


        print("Target: \(offset) Next offset: \(nextOffset)")
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToColumnEdge()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToColumnEdge()
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("Started decelerating")
    }

    private func scrollToColumnEdge() {
        if let offset = nextOffset {
            columnView.setContentOffset(offset, animated: true)
        }
    }
}

extension UIViewController: SizableViewController {
    var columnViewController: ColumnViewController? {
        return parent as? ColumnViewController ?? parent?.columnViewController
    }

    func persist() {

    }

    func desist() {

    }

    func openDetailsViewController() {

    }
}

