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

    /// The preferred horizontal size class of sizable.
    var preferredHorizontalSizeClass: UIUserInterfaceSizeClass? { get }
}
