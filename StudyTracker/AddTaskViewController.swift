//
//  AddTaskViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 21/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit
import EventKitUI
import EventKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var labelTaskName: UITextField!
    @IBOutlet weak var labelNotes: UITextField!
    @IBOutlet weak var switchAddNotification: UISwitch!
    @IBOutlet weak var sliderProgress: UISlider!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentAssessment:Assessment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelNotes.text = ""
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveTask(_ sender: UIButton) {
        if self.labelTaskName.text!.count > 0 {
            let newTask = Task(context: context)
            newTask.title = labelTaskName.text
            newTask.assessment = currentAssessment?.moduleName
            newTask.isReminderSet = switchAddNotification.isOn
            
            if let notes = labelNotes?.text {
                newTask.notes = notes
            }
            newTask.progress = sliderProgress.value
            newTask.startDate = Date()
            newTask.taskDueDate = datePicker.date
            
            newTask.isReminderSet = switchAddNotification.isOn
            
            currentAssessment?.addToHasTasks(newTask)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //sets reminder in default reminders application
            let title = self.labelTaskName.text!
            if switchAddNotification.isOn {
                // In newer iOS saves in reminders application:
                saveReminder(title: title, notes: self.labelNotes.text ?? "", dateDue: self.datePicker.date, setAlarm: true)
                // In order to save as event, use next line instead:
                //saveEventToCalendar(title: title, subtitle: "", notes: self.labelNotes.text ?? "", startDate: self.datePicker.date, setAlarm: true)
            }
           
            //close popover
            self.presentingViewController!.dismiss(animated: false, completion: nil)
        }
        else {
            showAlert("Incomplete Data", "Task name is missing")
        }
        
        
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
    }*/
    
    func showAlert (_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
}
