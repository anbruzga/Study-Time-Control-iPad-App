//
//  AddTaskViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 21/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit

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
            
            if(switchAddNotification.isOn){
                // TODO set notification
            }
            
            newTask.isReminderSet = switchAddNotification.isOn
            
            currentAssessment?.addToHasTasks(newTask)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //close popover
            self.presentingViewController!.dismiss(animated: false, completion: nil)
        }
        else {
            showAlert("Incomplete Data", "Task name is missing")
        }
        
      
    }


    func showAlert (_ title: String, _ message: String){
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
           alert.addAction(OKAction)
           self.present(alert, animated: true, completion: nil)
    }
}
