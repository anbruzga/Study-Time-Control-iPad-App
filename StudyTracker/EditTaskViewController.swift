//
//  EditTaskViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 21/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit

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
        
        // Do any additional setup after loading the view.
    }
    


    @IBAction func updateTask(_ sender: UIButton) {
        currentTask?.title = labelTaskName.text
        currentTask?.assessment = currentAssessment?.moduleName
        currentTask?.isReminderSet = switchAddNotif.isOn
        currentTask?.notes = labelNotes.text
        currentTask?.progress = sliderProgress.value
        currentTask?.taskDueDate = datePicker.date
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        //close popover
        self.presentingViewController!.dismiss(animated: false, completion: nil)
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
