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
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        //close popover
        self.presentingViewController!.dismiss(animated: false, completion: nil)
    }
    
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
