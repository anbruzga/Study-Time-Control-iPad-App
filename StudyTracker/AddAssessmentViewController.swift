//
//  AddAssessmentViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 20/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit
import EventKitUI

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
            
            //set reminder
            if saveToCal.isOn {
                saveToCalendar()
            }
            
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
    
    // MARK: - SAVE TO CALENDAR
    func saveToCalendar(){
        // checks for bad time
        let eventStartDate = datePicker.date
        if isDateAndTimePastNow(eventStartDate) {
            showAlert("Date error!", "Selected date is in the past")
            return
        }
        
        // create event in calendar
        // @@@@@@@@@@@@@@@@@@@@@@@@@@
        // Adapted from https://stackoverflow.com/questions/28379603/how-to-add-an-event-in-the-device-calendar-using-swift
        // answer by user toofani at https://stackoverflow.com/users/1782153/toofani
        let eventStore : EKEventStore = EKEventStore()
        
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    event.title = "" + self.module.text!  + ": " + self.type.text!
                    event.startDate = self.datePicker.date
                    
                    
                    event.endDate = self.datePicker.date.addingTimeInterval(3600 as TimeInterval) // todo 3600.. maybe ask the user??
                    if self.notes.text != "" {
                        event.notes = self.notes.text!
                    }
                    else {
                        event.notes = ""
                    }
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                        self.showAlert("Saving Failure", "Failed to save event to the calendar. Error:\n  \(error)")
                    }
                    print("Saved Event")
                    
                }
                self.showAlert("Event Saved", "Event Saved Successfully")
            }
            else{
                self.showAlert("Saving Failure", "failed to save event with error : \(error) or access not granted")
                print("failed to save event with error : \(error) or access not granted")
            }
        }
        // @@@@@@@@@@@@@@@@@@@@@@@@@@
        
        
    }
    
    // MARK: - UTILITIES
    func isDateAndTimePastNow(_ eventStartDate: Date) -> Bool {
        let currentDateTime = Date()
        return currentDateTime > eventStartDate
    }
    
    
    func showAlert (_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
