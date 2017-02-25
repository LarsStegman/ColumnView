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

    var repeating = 1

    override func loadView() {
        let label = UILabel()
        label.text = String.init(repeating: "yo", count: repeating)
        view = label
        view.backgroundColor = colors[colorCount]
        colorCount = (colorCount + 1) % colors.count
        self.preferredContentSize = view.intrinsicContentSize
    }

}

extension UIColor {
    static var randomColor: UIColor {
        switch arc4random() % 5 {
        case 0: return .purple
        case 1: return .green
        case 2: return .yellow
        case 3: return .red
        case 4: return .blue
        default: return .gray
        }
    }
}
