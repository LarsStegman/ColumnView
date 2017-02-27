//
//  Sizable.swift
//  ColumnView
//
//  Created by Lars Stegman on 10-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

/// Usually used by a UIViewController to respond to requests from the container column view controller.
protocol SizableViewController: class {
    /// Requests a string to show to the user that can be displayed when they try to open a details view controller.
    var stringForOpeningDetailsViewController: String? { get }

    /// Asks the child view controller to open a detail view controller, if applicable.
    func openDetailsViewController()

    /// The preferred horizontal size class of sizable.
    var preferredHorizontalSizeClass: UIUserInterfaceSizeClass? { get }
}
