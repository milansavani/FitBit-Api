//
//  HistoryVC.swift
//  SampleFitBit
//
//  Created by Mobiiworld on 9/5/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController {

    @IBOutlet var startDateField: UITextField!
    @IBOutlet var endDateField: UITextField!
    @IBOutlet var totalStepLabel: UILabel!
    var datePickerView = UIDatePicker()
    let healthManager = HealthManager()

    var isFitBit: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDatePicker()
        if let dict = (UserDefaults.standard.dictionary(forKey: "userObject")) {
            isFitBit = (dict["deviceType"] as! String) == "FitBit"
        }
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func dateFromFormat(_ date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date = dateFormatter.date(from: date)
        return date
    }
    
    func setDatePicker() {
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date()
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleDoneButton))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleCancelButton))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        endDateField.inputView = datePickerView
        endDateField.inputAccessoryView = toolBar
        startDateField.inputView = datePickerView
        startDateField.inputAccessoryView = toolBar
    }
    
    @objc func handleDoneButton() {
        if startDateField.isFirstResponder {
            startDateField.text = String(describing : datePickerView.date)
        } else {
            endDateField.text = String(describing : datePickerView.date)
        }
        datePickerView.date = Date()
        self.view.endEditing(true)
    }
    
    @objc func handleCancelButton() {
        self.view.endEditing(true)
    }
    
    @IBAction func tappedGetSteps(_ sender: Any) {
        isFitBit ? getStepFromFitBit() : getStepFromHealthKit()
    }
    
    
    func getStepFromHealthKit() {
        guard let startDate = dateFromFormat(startDateField.text!), let endDate = dateFromFormat(endDateField.text!) else {
            return
        }
        healthManager.fetchStepCount(startDate, endDate) { (steps, success) in
            DispatchQueue.main.async {
                if success {
                    self.totalStepLabel.text = String(Int(steps))
                } else {
                    self.totalStepLabel.text = "0"
                }
            }
        }
    }
    
    func getStepFromFitBit() {
        guard let startDate = dateFromFormat(startDateField.text!), let endDate = dateFromFormat(endDateField.text!) else {
            return
        }
        APIManager.fetchSteps(for: DateInterval(start: startDate, end: endDate)) { (success, json, error) in
            if success {
                var stepCount = 0
                for obj in (((json as! [String: Any])["activities-tracker-steps"]) as! NSArray) {
                    let objectStep = (obj as! [String: Any])["value"] as! String
                    stepCount = stepCount + (Int(objectStep) ?? 0)
                }
                
                DispatchQueue.main.async {
                    self.totalStepLabel.text = String(stepCount)
                }
            }
        }
    }
}
