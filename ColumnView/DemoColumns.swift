//
//  DemoColumns.swift
//  ColumnView
//
//  Created by Lars Stegman on 19-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class DemoColumns: ColumnViewController {
    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            let label = DemoLabelController()
            label.repeating = 18
            self.addColumn(vc: label, animated: true, focus: true)
        }
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { (timer) in
            let label = DemoLabelController()
            label.repeating = 18
            self.addColumn(vc: label, animated: true, focus: true)
        }
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { (timer) in
            let label = DemoLabelController()
            label.repeating = 30
            self.addColumn(vc: label, animated: true, focus: true)
        }
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (timer) in
            let label = DemoLabelController()
            label.repeating = 80
            self.addColumn(vc: label, animated: true, focus: true)
        }
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            let label = DemoLabelController()
            label.repeating = 80
            self.addColumn(vc: label, animated: true, focus: true)
        }
    }
}

