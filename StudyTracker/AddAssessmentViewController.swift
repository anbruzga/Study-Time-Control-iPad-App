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
        // Do any additional setup after loading the view.
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
            newAssessment.value = self.value.text // number, optional // TODO
            newAssessment.markAwarded = self.markAchieved.text // optional, number. Allowed only for editing, takes into account date ?? Todo
            
            newAssessment.reminderDate = datePicker.date // extract date for saving if saveToCal is true
            newAssessment.isReminderSet = saveToCal.isOn // save if on
            newAssessment.dateWhenSet = Date()
            
        
            //set reminder in default reminders application
            let title = self.module.text! + ": " + self.type.text!
            if saveToCal.isOn {
                saveReminder(title: title, notes: self.notes.text ?? "", dateDue: self.datePicker.date, setAlarm: true)
            }
            
            // set event in default events application
            saveEventToCalendar(title: title, subtitle: "", notes: self.notes.text ?? "", startDate: self.datePicker.date, setAlarm: true)
            
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
                //pass
            }
            else if (!isNum(val)){
                showAlert("Syntax Error", "Wrong input type: " + val + " is not a number")
                return false
            }
        }
        
        if let mark = self.markAchieved.text {
            if(mark == ""){
                //pass
            }
            else if (!isNum(mark)){
                showAlert("Syntax Error", "Wrong input type: " + mark + " is not a number")
                return false
            }
        }
        return true
    }
    
    func isNum(_ val: String) -> Bool {
        return (val.lowercased() == val.uppercased() && val.isNumber)
    }
    /*
    // MARK: - SAVE TO CALENDAR
    func saveReminder(){
        
        
        // checks for bad time
        let eventStartDate = datePicker.date
        if isDatePastNow(eventStartDate) {
            showAlert("Date error!", "Selected date is in the past")
            return
        }
        
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: EKEntityType.reminder, completion:
            {(granted, error) in
                if (granted) && (error == nil) {
                    print("granted \(granted)")
                    print("error \(String(describing: error))")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let reminder: EKReminder = EKReminder(eventStore: eventStore)
                        let reminderTitle: String = self.module.text! + " : " + self.type.text!
                        reminder.title = reminderTitle
                        reminder.notes = self.notes.text
                        
                        let  dueDateComp = dateComponentFromDate(self.currentAssessment!.reminderDate!)
                        print("DATE: ")
                        print("\(self.currentAssessment!.reminderDate!.description)")
                        reminder.dueDateComponents = dueDateComp
                        reminder.calendar = eventStore.defaultCalendarForNewReminders()
                        //reminder.calendar = eventStore.defaultCalendarForNewEvents
                        do {
                            try eventStore.save(reminder, commit: true)
                            
                        }catch{
                            print("Error creating and saving new reminder : \(error)")
                        }
                    }
                }
        }
        )
    }
    
    */
    
    
    // MARK: - UTILITIES
    func showAlert (_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
