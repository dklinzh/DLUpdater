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
    
    private let updater = DLUpdater()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updater.check(alertCustom: true) { (results) in
            switch results {
            case .success(let updateResults):
                print("AlertAction: ", updateResults.alertAction)
                print("Localization: ", updateResults.localization)
                print("Model: ", updateResults.model)
                print("UpdateType: ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

