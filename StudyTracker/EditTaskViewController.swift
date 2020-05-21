//
//  EditTaskViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 21/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit

class EditTaskViewController: UIViewController {

    @IBOutlet weak var labelTaskName: UITextField!
    @IBOutlet weak var textViewNotes: UITextView!
    @IBOutlet weak var switchAddNotif: UISwitch!
    @IBOutlet weak var sliderProgress: UISlider!
    var currentAssessment: Assessment?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func updateTask(_ sender: UIButton) {
        
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
