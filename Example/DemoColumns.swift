//
//  DemoColumns.swift
//  ColumnView
//
//  Created by Lars Stegman on 19-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import UIKit

class DemoColumns: ColumnViewController {

    private var performInitialSegue = false
    override func viewDidLoad() {
        performInitialSegue = true
    }

    override func viewWillAppear(_ animated: Bool) {
        if performInitialSegue {
            performInitialSegue = false
            performSegue(withIdentifier: "embedInitialColumn", sender: nil)
        }
    }
}

