//
//  AddAssessmentViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 20/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit
import EventKitUI
import EventKit

//@@@@@@@@@@@@@@@@@@@@@@@@
// taken from https://stackoverflow.com/questions/26545166/how-to-check-is-a-string-or-number
// answer of CryingHippo at https://stackoverflow.com/users/4720722/cryinghippo
extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
//@@@@@@@@@@@@@@@@@@@@@@@@

class AddAssessmentViewController: UIViewController {
    
    
    @IBOutlet weak var module: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var markAchieved: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveToCal: UISwitch!
    
    var currentAssessment: Assessment?
    
    //get handle to the context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if (UserDefaults.standard.integer(forKey: "addAssessmentPopoverActive") == 1){
            UserDefaults.standard.string(forKey: "addAssessmentModule")
            self.notes.text =  UserDefaults.standard.string(forKey: "addAssessmentNotes")
            self.value.text  = UserDefaults.standard.string(forKey: "addAssessmentText")
            self.markAchieved.text =  UserDefaults.standard.string(forKey: "addAssessmentMark")
          //  self.datePicker.date =  UserDefaults.standard.object(forKey: "addAssessmentDatePicker") as! Date
            self.saveToCal.isOn =   UserDefaults.standard.bool(forKey: "addAssessmentSaveToCal")
        }*/
        
        UserDefaults.standard.set(1, forKey: "addAssessmentPopoverActive")
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
       /*
        UserDefaults.standard.set(self.module.text, forKey: "addAssessmentModule")
        UserDefaults.standard.set(self.notes.text, forKey: "addAssessmentNotes")
        UserDefaults.standard.set(self.value.text, forKey: "addAssessmentText")
        UserDefaults.standard.set(self.markAchieved.text, forKey: "addAssessmentMark")
        UserDefaults.standard.set(self.datePicker.date, forKey: "addAssessmentDatePicker")
        UserDefaults.standard.set(self.saveToCal.isOn, forKey: "addAssessmentSaveToCal")
        */
        UserDefaults.standard.set(0, forKey: "addAssessmentPopoverActive")
        super.viewWillDisappear(animated)
    }
    
    // MARK: ONCLICK
    @IBAction func saveAssessment(_ sender: UIButton) {
        
        
        if self.module.text!.count > 0 && self.type.text!.count > 0 {
            //Validation
            if(!validation()){
                return
            }
            
            let newAssessment = Assessment(context: context)
            newAssessment.moduleName = self.module.text // mandatory
            newAssessment.notes = self.notes.text // optional
            newAssessment.type = self.type.text // mandatory
            newAssessment.value = self.value.text // number, optional
            newAssessment.markAwarded = self.markAchieved.text // optional, number. Allowed only for editing, takes into account date
            
            newAssessment.reminderDate = datePicker.date // extract date for saving 
            newAssessment.isReminderSet = saveToCal.isOn // save if on
            newAssessment.dateWhenSet = Date()
            
            
            
            
            
            //set reminder in default reminders application
            let title = self.module.text! + ": " + self.type.text!
            if saveToCal.isOn {
                saveReminder(title: title, notes: self.notes.text ?? "", dateDue: self.datePicker.date, setAlarm: true)
            }
            
            // set event in default events application
            saveEvent(title: title, subtitle: "", notes: self.notes.text ?? "", startDate: self.datePicker.date, setAlarm: true)
            
            currentAssessment = newAssessment
            
            
            //savecontext
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //close popover
            self.presentingViewController!.dismiss(animated: false, completion: nil)
            
        } else{
            showAlert("Missing Data", "Module and Assessment fields must be not empty" )
            return
            
        }
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
        
        if let mark = self.markAchieved.text {
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
    
    
    
    // MARK: - UTILITIES
    func showAlert (_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
