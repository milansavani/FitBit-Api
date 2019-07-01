//
//  ViewController.swift
//  SampleFitBit
//
//  Created by mobiiworld on 27/06/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var getValue: UIButton!
    @IBOutlet weak var resultView: UITextView!
    var authenticationController: AuthenticationController?
    
    private var optionsArray = ["Profile", "Activities", "Steps", "Calories"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FitBit Demo"
        authenticationController = AuthenticationController(delegate: self)
        if !(AuthenticationController.getToken().isEmpty) {
            self.setBtnAfterAuthToken()
            self.resultView.text = "Ready to fetch Value"
        }
    }
    
    // MARK: Actions
    @IBAction func login(_ sender: AnyObject) {
        authenticationController?.login(fromParentViewController: self)
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        AuthenticationController.logout { (success, json, error) in
            if success {
                DispatchQueue.main.async {
                    self.resultView.text = "Please press login to authorize"
                    self.getValue.isUserInteractionEnabled = false
                    self.getValue.backgroundColor = UIColor.lightGray
                }
            }
        }
    }
    
    @IBAction func getValue(_ sender: AnyObject) {
        let alertController = AppAlertController(title: nil, message: nil, optionsArray: optionsArray, tintColor: appColor, cancelText: "Cancel")
        alertController.didTap = { (index, option) in
            switch index {
            case 0:
                self.getProfile()
                break
                
            case 1:
                self.getActivities()
                break
            
            case 2:
                self.getSteps()
                break
                
            case 3:
                self.getCalories()
            default:
                break
                
            }
        }
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    private func getProfile() {
        APIManager.getProfile { (success, json, error) in
            if success {
                DispatchQueue.main.async {
                    self.resultView.text = self.jsonToString(json: json as AnyObject)
                }
            }
        }
    }
    
    
    private func getActivities() {
        APIManager.fetchActivities(for: Date()) { (success, json, error) in
            if success {
                DispatchQueue.main.async {
                    self.resultView.text = self.jsonToString(json: json as AnyObject)
                }
            }
        }
    }
    
    private func getSteps() {
        
        APIManager.fetchSteps(for: DateInterval(start: Date(timeIntervalSince1970: 1561800731), end: Date())) { (success, json, error) in
            if success {
                DispatchQueue.main.async {
                    self.resultView.text = self.jsonToString(json: json as AnyObject)
                }
            }
        }
    }
    
    
    private func getCalories() {
        APIManager.fetchCalories(for: DateInterval(start: Date(timeIntervalSince1970: 1561800731), end: Date())) { (success, json, error) in
            if success {
                DispatchQueue.main.async {
                    self.resultView.text = self.jsonToString(json: json as AnyObject)
                }
            }
        }
    }
    
    private func jsonToString(json: AnyObject) -> String? {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8)
            return convertedString
            
        } catch {
            return nil
        }
    }
    
    private func setBtnAfterAuthToken() {
        self.getValue.isUserInteractionEnabled = true
        self.getValue.backgroundColor = appColor
    }
}

//MARK:-
// MARK: AuthenticationProtocol
extension ViewController: AuthenticationProtocol {
    func authorizationDidFinish(_ success: Bool) {
        guard let authToken = authenticationController?.authenticationToken else {
            return
        }
        self.resultView.text = "Ready to fetch Value"
        AuthenticationController.setToken(token: authToken)
        setBtnAfterAuthToken()
    }
}

