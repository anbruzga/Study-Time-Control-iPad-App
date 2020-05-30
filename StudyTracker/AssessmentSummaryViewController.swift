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
    @IBOutlet weak var progressViewForPercentCompleted: UIProgressView!
    @IBOutlet weak var labelDaysLeft: UILabel!
    @IBOutlet weak var progressViewForDaysLeft: UIProgressView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(initAllFields), name: NSNotification.Name(rawValue: "reloadAssessmentSummary"), object: currentAssessment)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadEmptyFields), name: NSNotification.Name(rawValue: "loadNilAssessmentSummary"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPercentCompleted), name: NSNotification.Name(rawValue: "reloadPercentCompletedProgressBar"), object: nil)
        
        
        initAllFields()
        
        
    }
    @objc func reloadPercentCompleted(notification: NSNotification){
        progressViewForPercentCompleted.progress = AvgProgress.getAvg()
        let cleanedPercent = round(AvgProgress.getAvg() * 100.0).clean
        labelPercentCompleted.text = String(cleanedPercent) + " %"
        print (labelPercentCompleted.text)
    }
    
    @objc func loadEmptyFields(notification: NSNotification){
        moduleTitle.text = ""
        assessmentType.text = ""
        assessmentNotes.text = ""
        progressViewForDaysLeft.isHidden = true
        progressViewForPercentCompleted.isHidden = true
        labelDaysLeft.text = ""
        labelPercentCompleted.text = ""
        
    }
    
    @objc func initAllFields(){
        moduleTitle.text = currentAssessment?.moduleName
        assessmentType.text = currentAssessment?.type
        assessmentNotes.text = currentAssessment?.notes
        initDaysLeft()
        if currentAssessment == nil {
            progressViewForDaysLeft.isHidden = true
            progressViewForPercentCompleted.isHidden = true
            
        }
        else {
            progressViewForPercentCompleted.isHidden = false
            progressViewForDaysLeft.isHidden = false
        }
        
        if (currentAssessment?.hasTasks?.count ?? 0 <= 0) {
            progressViewForPercentCompleted.isHidden = true
        }
        
        
    }
    
    func initDaysLeft(){
        if let dateDue = currentAssessment?.reminderDate {
            let dateNow = Date()
            
            // if in the past
            if(dateNow > dateDue){
                labelDaysLeft.text = "Past Deadline"
                progressViewForDaysLeft.progress = 1.0
                return
            }
            
            let minutesDiff: Int = absMinutesBetweenTwoDates(dateNow, dateDue)
            let describedTimeLeft: String = describeMinutes(minutes: minutesDiff)
            labelDaysLeft.text = describedTimeLeft
            
            
            // setting up PROGRESS VIEW for days left
            let dateWhenSet = currentAssessment?.dateWhenSet
            let currentProgress: Int = absMinutesBetweenTwoDates(dateNow, dateWhenSet!)
            let maxProgress: Int = absMinutesBetweenTwoDates(dateWhenSet!, dateDue)
            print("ASSESSMENT: \(String(describing: currentAssessment?.moduleName))")
            
            
            if (maxProgress != 0) { // to avoid division by 0
                let progressRatio: Float = Float(Float(currentProgress)/Float(maxProgress))
                self.progressViewForDaysLeft.progress = progressRatio
                print("Current progress \(currentProgress)")
                print("Max progress \(maxProgress)")
                print("Progress ratio \(progressRatio)")
                
                if(progressRatio > 1 && labelDaysLeft.text! != "Past deadline"){
                    print("UNEXPECTED RATIO")
                }
                
            }
            else {  // can happen if  dateWhenSet and dateDue is same or has less than one minute difference
                print("ASSESMENT  MAX PROGRESS IS 0")
                print("DATE WHEN SET: \(String(describing: dateWhenSet?.description))")
                print("DATE DUE: \(String(describing: dateDue.description))")
                self.progressViewForDaysLeft.progress = 1
            }
            
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
