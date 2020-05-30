//
//  EditTaskViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 21/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit
import EventKitUI
import EventKit

class EditTaskViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var labelTaskName: UITextField!
    @IBOutlet weak var labelNotes: UITextField!
    @IBOutlet weak var switchAddNotif: UISwitch!
    @IBOutlet weak var sliderProgress: UISlider!
    @IBOutlet weak var datePicker: UIDatePicker!
    var currentAssessment: Assessment?
    var currentTask: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        labelTaskName.text = currentTask?.title
        labelNotes.text = currentTask?.notes
        //todo rethink switch on and of. Will kind of encourage duplicates in calendar
        switchAddNotif.setOn(currentTask?.isReminderSet ?? false, animated: false)
        sliderProgress.setValue(currentTask?.progress ?? 0.0 , animated: false)
        datePicker.date = currentTask?.taskDueDate ?? Date()
        
        print("labelTaskName \(String(describing: labelTaskName))")
        
        
        if labelTaskName.text == "" {
            print("here")
            self.presentingViewController!.dismiss(animated: false, completion: nil)
        }
        
        
        
    }
    
    
    
    @IBAction func updateTask(_ sender: UIButton) {
        currentTask?.title = labelTaskName.text
        currentTask?.assessment = currentAssessment?.moduleName
        currentTask?.isReminderSet = switchAddNotif.isOn
        currentTask?.notes = labelNotes.text
        currentTask?.progress = sliderProgress.value
        currentTask?.taskDueDate = datePicker.date
       // currentTask?.startDate = Date()
        
      //sets reminder in default reminders application
        let title = self.labelTaskName.text!
        if switchAddNotif.isOn {
            // In newer iOS saves in reminders application:
            saveReminder(title: title, notes: self.labelNotes.text ?? "", dateDue: self.datePicker.date, setAlarm: true)
            // In order to save as event, use next line instead:
            //saveEventToCalendar(title: title, subtitle: "", notes: self.labelNotes.text ?? "", startDate: self.datePicker.date, setAlarm: true)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        //close popover
        self.presentingViewController!.dismiss(animated: false, completion: nil)
    }
   
    /*
    // MARK: - SAVE TO CALENDAR
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
                           let reminderTitle: String = "Task:" + self.labelNotes.text!
                           reminder.title = reminderTitle
                           reminder.notes = self.labelTaskName.text
                           
                           let  dueDateComp = dateComponentFromDate(self.datePicker.date)
                           reminder.dueDateComponents = dueDateComp
                           reminder.calendar = eventStore.defaultCalendarForNewReminders()
                         //  reminder.calendar = eventStore.defaultCalendarForNewEvents
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
    
    
    func showAlert (_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
}
