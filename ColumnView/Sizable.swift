//
//  Sizable.swift
//  ColumnView
//
//  Created by Lars Stegman on 10-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

/// Usually used by a UIView to indicate size preferences/values for a container column view.
protocol SizableView: class {

    /// The preferred size in a horizontally compact environment
    var preferredHorizontalCompactContentSize: CGSize { get }

    /// The preferred size in a horizontally regular environment.
    var preferredHorizontalRegularContentSize: CGSize { get }

    /// The preferred horizontal size class of sizable.
    var preferredHorizontalSizeClass: UIUserInterfaceSizeClass { get }
}

/// Usually used by a UIViewController to respond to requests from the container column view controller.
protocol SizableViewController: class {
    /// Informs sizable that it will persist in the container view.
    func persist()

    /// Informs sizable that it will no longer persist in the container view.
    func desist()

    /// Asks the child view controller to open a detail view controller, if applicable.
    func openDetailsViewController()
}
