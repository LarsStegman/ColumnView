//
//  ShowDemoViewController.swift
//  ColumnView
//
//  Created by Lars Stegman on 08-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import UIKit

class ShowDemoViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        preferredContentSize = CGSize(width: 400, height: 700)
        columnViewController?.preferredHorizontalSizeClassDidChange(forChildViewController: self)
    }

    private var lastPresented: UIViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "dismissAndShow" {
            
            lastPresented = segue.destination
        }
    }
}
