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

class ColumnViewController: UIViewController {

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
    }

    override func viewDidAppear(_ animated: Bool) {
        let button = UIButton()
        button.setTitle("Hello, world!", for: .normal)
        button.backgroundColor = .green
        columnView.add(column: button)

        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ut dui volutpat, mollis ligula sed, accumsan sapien. Aenean efficitur metus et sagittis posuere. Sed dapibus massa vitae volutpat mollis. Integer congue euismod dolor, a pulvinar ex elementum in. Cras vitae libero id ligula iaculis imperdiet. Aliquam malesuada orci in nulla iaculis vehicula. Suspendisse sed mauris vitae tortor efficitur iaculis. Aenean et gravida dolor. Duis tristique massa ac imperdiet commodo. "
        label.backgroundColor = .red
        columnView.add(column: label)
    }
}

extension UIViewController: SizableViewController {
    func persist() {

    }

    func desist() {

    }

    func openDetailsViewController() {

    }
}

