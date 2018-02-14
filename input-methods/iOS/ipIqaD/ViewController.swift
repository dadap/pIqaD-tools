//
//  ViewController.swift
//  ipIqaD
//
//  Created by Daniel Dadap on 1/15/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func installProfile(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://dadap.github.io/pIqaD-tools/input-methods/iOS/pIqaD/profiles/pIqaD-qolqoS.mobileconfig")!)
    }

}

