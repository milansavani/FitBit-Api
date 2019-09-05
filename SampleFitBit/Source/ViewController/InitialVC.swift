//
//  InitialVC.swift
//  SampleFitBit
//
//  Created by Mobiiworld on 9/5/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedFitBit(_ sender: Any) {
        let dict = ["deviceType" : "ViewController" , "initialLogin" : Date()] as [String : Any]
        let defaults = UserDefaults.standard
        defaults.set(dict, forKey: "userObject")
        defaults.synchronize()
        
    }
    
    @IBAction func tappedHealthKit(_ sender: Any) {
        let dict = ["deviceType" : "StepCountViewController" , "initialLogin" : Date()] as [String : Any]
        let defaults = UserDefaults.standard
        defaults.set(dict, forKey: "userObject")
        defaults.synchronize()
    }
    
}
