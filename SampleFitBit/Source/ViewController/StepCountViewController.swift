//
//  ViewController.swift
//  StepStats
//
//  Created by Mayank Kumar on 4/15/16.
//  Copyright © 2016 Mayank Kumar. All rights reserved.
//

import UIKit

class StepCountViewController: UIViewController {
    
    let healthManager = HealthManager()
    @IBOutlet var stepCountLabel: UILabel!
    @IBOutlet var welcomeDescription: UILabel!
    @IBOutlet var logout: UIButton!
    @IBOutlet weak var label: UILabel!
    var startTime = Date()
    var isFitBit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dict = (UserDefaults.standard.dictionary(forKey: "userObject")) {
            if (dict["deviceType"] as! String) == "HealthKit" {
                isFitBit = false
                self.label.text = "HelathKit"
                self.logout.isHidden = !isFitBit
                fetchInformation()
            } else {
                isFitBit = true
                self.label.text = "FitBit"
                self.logout.isHidden = !isFitBit
                getSteps()
            }
        }
        self.title = isFitBit ? "FitBit" : "HealthKit"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationItem.hidesBackButton = true
    }
    
    //MARK:-
    //MARK:- IBActions
    @IBAction func tappedLogout(_ sender: AnyObject) {
        self.fitBitLogout()
    }
    
    @IBAction func tappedOtherDevice(_ sender: Any) {
        self.presentAlertWithTitle(title: "", message: "Changing the device will reset your steps", options: "Yes" , "No") { (option) in
            switch (option) {
            case 0:
                if self.isFitBit {
                    self.fitBitLogout()
                } else {
                    DispatchQueue.main.async {
                        UserDefaults.standard.removeObject(forKey: "userObject")
                        UserDefaults.standard.synchronize()
                        self.navigationController?.popViewController(animated: true)
                        AppDelegate.appdelegate.moveToInitial()
                    }
                    
                }
            case 1:
                break
            default:
                break
            }
            
        }
    }
    
    @IBAction func tappedHistory(_ sender: Any) {
        
    }
    
    //MARK:-
    //MARK:- Custom Actions
    private func getSteps() {
         startTime = ((UserDefaults.standard.dictionary(forKey: "userObject") as! [String : Any])["initialLogin"] as? Date)!
        APIManager.fetchSteps(for: DateInterval(start: startTime, end: Date())) { (success, json, error) in
            if success {
                var stepCount = 0
                for obj in (((json as! [String: Any])["activities-tracker-steps"]) as! NSArray) {
                    let objectStep = (obj as! [String: Any])["value"] as! String
                    stepCount = stepCount + (Int(objectStep) ?? 0)
                }
                
                DispatchQueue.main.async {
                    self.stepCountLabel.text = String(stepCount)
                }
            }
        }
    }
    
    private func fitBitLogout() {
        AuthenticationController.logout { (success, json, error) in
            if success {
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: "userObject")
                    UserDefaults.standard.synchronize()
                    self.navigationController?.popViewController(animated: true)
                    AppDelegate.appdelegate.moveToInitial()
                }
            }
        }
    }
    
    private func fetchInformation() {
        if !healthManager.checkAuth() {
            stepCountLabel.text = "-"
            welcomeDescription.text = "API Access Denied"
        }
        else {
            welcomeDescription.text = "You've covered"
            startTime = ((UserDefaults.standard.dictionary(forKey: "userObject") as! [String : Any])["initialLogin"] as? Date)!
            healthManager.listenForUpdates(startDate : startTime){ steps, success in
                DispatchQueue.main.async {
                    if success {
                        print(steps)
                        self.stepCountLabel.text = String(Int(steps))
                    }
                }
            }
        }
    }
}

//MARK:-
extension UIViewController {
    
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
