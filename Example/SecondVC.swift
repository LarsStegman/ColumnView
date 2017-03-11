//
//  SecondVC.swift
//  ColumnView
//
//  Created by Lars Stegman on 10-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import UIKit

class SecondVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        print(presentingViewController)
    }

}
