//
//  AssessmentSummaryViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 21/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit

class AssessmentSummaryViewController: UIViewController {
    
    var currentAssessment: Assessment?
    @IBOutlet weak var moduleTitle: UILabel!
    @IBOutlet weak var assessmentType: UILabel!
    @IBOutlet weak var assessmentNotes: UITextView!
    @IBOutlet weak var labelPercentCompleted: UILabel!
    @IBOutlet weak var progressViewForPercentCompleted: NSLayoutConstraint!
    @IBOutlet weak var labelDaysLeft: UILabel!
    @IBOutlet weak var progressViewForDaysLeft: UIProgressView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moduleTitle.text = currentAssessment?.moduleName
        assessmentType.text = currentAssessment?.type
        assessmentNotes.text = currentAssessment?.notes
        initDaysLeft()
        
    }
    
    func initDaysLeft(){
        if let dateDue = currentAssessment?.reminderDate {
            var days: String = "0"
            var hours: String = "0"
            let dateNow = Date()
            
            // if in the past
            if(dateNow > dateDue){
                labelDaysLeft.text = "Past deadline"
            }
                // if in a day time - display hours left
            else if(dateNow.advanced(by: -86400 as TimeInterval) < dateDue) { // advanced by a day
                let cal = Calendar.current
                let components = cal.dateComponents([.hour], from: dateNow, to: dateDue)
                let diff = components.hour!
                let dateString = "\(diff)"
                if(Int(dateString)! >= 24 ) { // if >= than day, display in hours and days
                    hours = String(Int(dateString)! % 24) // hours
                    days = String(Int(dateString)! / 24) // days
                    //todo fix grammar
                    labelDaysLeft.text =  days + " Days " + " and " + hours + " hours left"
                }
                else { // else display just hours
                    labelDaysLeft.text = "" + dateString + " hours left"
                }
                
            }
            
            // setting up PROGRESS VIEW for days left
            let cal = Calendar.current
            let currentProgress = Int(days)! * 24 + Int(hours)!
            let components = cal.dateComponents([.hour], from: (currentAssessment?.dateWhenSet)!, to: dateDue)
            let diff = components.hour!
            let hoursString = "\(diff)"
            // This is displaying diff between date due and date now!!! TODO
            // MAX PROGRESS is 1 - (RATIO in hrs of dateWhenSet of assessment AND dueTime)
            let maxProgress = Int(hoursString)! //hours in week
            let progressRatioReversed = Float(1 - (Float(currentProgress) / Float(maxProgress)))
            progressViewForDaysLeft.progress = Float(progressRatioReversed)
            
        }
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
