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
    //todo add guards
    @IBAction func updateAssessment(_ sender: UIButton) {
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
        saveEventToCalendar(title: title, subtitle: "", notes: self.notes.text ?? "", startDate: self.datePicker.date, setAlarm: true)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        //close popover
        self.presentingViewController!.dismiss(animated: false, completion: nil)
    }
    
    func showAlert (_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
 /*   // MARK: - SAVE TO CALENDAR
    func saveToCalendar(){
        
        
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
                        do {
                            try eventStore.save(reminder, commit: true)
                            
                        }catch{
                            print("Error creating and saving new reminder : \(error)")
                        }
                    }
                }
        }
        )
    }*/
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
