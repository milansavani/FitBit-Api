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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDatePicker()
    }
    
    func dateFromFormat(_ date: String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date = dateFormatter.date(from: date)
        return date!
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
        healthManager.fetchStepCount(dateFromFormat(startDateField.text!), dateFromFormat(endDateField.text!)) { (steps, success) in
            DispatchQueue.main.async {
                if success {
                    self.totalStepLabel.text = String(Int(steps))
                } else {
                    self.totalStepLabel.text = "0"
                }
            }
        }
    }
    
    

}
