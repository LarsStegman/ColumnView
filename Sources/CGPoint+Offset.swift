//
//  CGPoint+Offset.swift
//  ColumnView
//
//  Created by Lars Stegman on 08-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}
