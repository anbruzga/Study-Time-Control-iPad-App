//
//  EditAssessmentViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 20/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit
import EventKitUI

class EditAssessmentViewController: UIViewController {
    var currentAssessment: Assessment?
    
    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var module: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var mark: UITextField!
    @IBOutlet weak var saveToCal: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(1, forKey: "editAssessmentPopoverActive")
        
        module.text = currentAssessment?.moduleName
        type.text = currentAssessment?.type
        value.text = currentAssessment?.value
        notes.text =  currentAssessment?.notes
        mark.text = currentAssessment?.markAwarded
        datePicker.date = currentAssessment?.reminderDate ?? Date()
        
        if (currentAssessment?.isReminderSet.self ?? false){ // if reminder was set, turn switch on
            
            saveToCal.setOn(true, animated: false)
        }
        else{
            saveToCal.setOn(false, animated: false)
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(0, forKey: "editAssessmentPopoverActive")
    }
    
    
    @IBAction func updateAssessment(_ sender: UIButton) {
        
        if self.module.text!.count > 0 && self.type.text!.count > 0 {
            //Validation
            if(!validation()){
                return
            }
            
            currentAssessment?.moduleName = module.text
            currentAssessment?.type = type.text
            currentAssessment?.value = value.text
            currentAssessment?.notes = notes.text
            currentAssessment?.markAwarded = mark.text
            currentAssessment?.isReminderSet = saveToCal.isOn
            currentAssessment?.reminderDate = datePicker.date
            currentAssessment?.dateWhenSet = Date()
            
            //set reminder in default reminders application
            let title = self.module.text! + ": " + self.type.text!
            if saveToCal.isOn {
                saveReminder(title: title, notes: self.notes.text ?? "", dateDue: self.datePicker.date, setAlarm: true)
            }
            
            // set event in default events application
            saveEvent(title: title, subtitle: "", notes: self.notes.text ?? "", startDate: self.datePicker.date, setAlarm: true)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //close popover
            self.presentingViewController!.dismiss(animated: false, completion: nil)
            
        } else{
            showAlert("Missing Data", "Module and Assessment fields must be not empty" )
            return
            
        }
    }
    
    func showAlert (_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - VALIDATION
    func validation() -> Bool{
        //Checking if value and mark are numeric
        if let val = self.value.text {
            if(val == ""){
                return true
            }
            
            
            if (!isNum(val)){
                showAlert("Error", "Mark should be in range 0 to 100")
                return false
            }
            if (Double(val) ?? -1 > 100 || Double(val) ?? -1 < 0) {
                showAlert("Syntax Error", "Value should be in range 0 to 100")
                return false
            }
        }
        
        if let mark = self.mark.text {
            if(mark == ""){
                return true
            }
            if (datePicker.date > Date().advanced(by: 60 as TimeInterval)){ // one minute to fix issues when adding on the spot
                showAlert("Syntax Error", "Mark can only be set for the past assessments")
                return false
            }
            if (!isNum(mark)){
                showAlert("Syntax Error", "Mark should be in range 0 to 100")
                return false
            }
            if (Double(mark) ?? -1 > 100 || Double(mark) ?? -1 < 0) {
                showAlert("Syntax Error", "Mark should be in range 0 to 100")
                return false
            }
        }
        return true
    }
    
    func isNum(_ val: String) -> Bool {
        return (val.lowercased() == val.uppercased() && val.isNumber)
    }
    
    
}
