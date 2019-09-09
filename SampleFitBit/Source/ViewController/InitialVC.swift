//
//  InitialVC.swift
//  SampleFitBit
//
//  Created by Mobiiworld on 9/5/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {

    var authenticationController: AuthenticationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedFitBit(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let someDateTime = formatter.date(from: "2019/08/01")
        authenticationController = AuthenticationController(delegate: self)
        authenticationController?.login(fromParentViewController: self)
        let dict = ["deviceType" : "FitBit" , "initialLogin" : someDateTime!] as [String : Any]
        let defaults = UserDefaults.standard
        defaults.set(dict, forKey: "userObject")
        defaults.synchronize()
        
    }
    
    @IBAction func tappedHealthKit(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let someDateTime = formatter.date(from: "2019/08/01")
        let dict = ["deviceType" : "HealthKit" , "initialLogin" : someDateTime!] as [String : Any]
        let defaults = UserDefaults.standard
        defaults.set(dict, forKey: "userObject")
        defaults.synchronize()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "StepCountViewController") as! StepCountViewController
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK:-
// MARK: AuthenticationProtocol
extension InitialVC: AuthenticationProtocol {
    func authorizationDidFinish(_ success: Bool) {
        guard let authToken = authenticationController?.authenticationToken else {
            return
        }
        AuthenticationController.setToken(token: authToken)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "StepCountViewController") as! StepCountViewController
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
