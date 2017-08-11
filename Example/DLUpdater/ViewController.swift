//
//  ViewController.swift
//  DLUpdater
//
//  Created by Daniel Lin on 08/12/2016.
//  Copyright (c) 2016 Daniel Lin. All rights reserved.
//

import UIKit
import DLUpdater

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        DLUpdater.shared.checkUpdate(type: .immediately) { (shouldUpdate: Bool, error: NSError?) in
            // 
            print(error?.description ?? "no error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

