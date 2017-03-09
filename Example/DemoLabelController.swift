//
//  DemoLabelController.swift
//  ColumnView
//
//  Created by Lars Stegman on 19-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit
var colorCount = 0
var colors = [UIColor.purple, .green, .yellow, .red, .blue]
class DemoLabelController: UIViewController {

    @IBInspectable var repeating = 1

    override func loadView() {
        let label = UILabel()
        label.text = String.init(repeating: "yo", count: repeating)
        view = label
        view.backgroundColor = colors[colorCount]
        colorCount = (colorCount + 1) % colors.count
        self.preferredContentSize = view.intrinsicContentSize
    }

}
