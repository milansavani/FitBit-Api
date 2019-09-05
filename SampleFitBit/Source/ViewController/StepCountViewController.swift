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
    var startTime = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HealthKit"
        fetchInformation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        fetchInformation()
    }
    
    func fetchInformation() {
        if !healthManager.checkAuth() {
            stepCountLabel.text = "-"
            welcomeDescription.text = "API Access Denied"
        }
        else {
            welcomeDescription.text = "You've covered"
            healthManager.listenForUpdates(startDate : ((UserDefaults.standard.dictionary(forKey: "userObject") as! [String : Any])["initialLogin"] as? Date)!){ steps, success in
                DispatchQueue.main.async {
                    if success {
                        print(steps)
                        self.stepCountLabel.text = String(Int(steps))
                    }
                }
            }
        }
    }
    
    @IBAction func tappedOtherDevice(_ sender: Any) {
        self.presentAlertWithTitle(title: "", message: "Changing the device will reset your steps", options: "Yes" , "No") { (option) in
            switch (option) {
            case 0:
                self.navigationController?.popViewController(animated: true)
            case 1:
                break
            default:
                break
            }
            
        }
    }
    
    @IBAction func tappedHistory(_ sender: Any) {
        
    }
    
    
}

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
