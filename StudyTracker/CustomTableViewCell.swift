//
//  CustomTableViewCell.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 22/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellNo: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var percentCompleted: UILabel!
    @IBOutlet weak var progressBarPercentLeft: CircularProgressView!
    @IBOutlet weak var progressBarDaysLeft: ProgressBarDaysLeft!
    @IBOutlet weak var daysLeft: UILabel!
    
    
    public var cellNoStr: String = ""
    public var titleStr: String = ""
    public var notesStr: String = ""
    public var percentCompletedStr: String = ""
    public var progressBarPercentLeftStr: String = ""
    public var progressBarDaysLeftStr: String = ""
    public var daysLeftStr: String = ""
  

    override func awakeFromNib() {
        super.awakeFromNib()
        cellNo.text = cellNoStr
        title.text = titleStr
        notes.text = notesStr
        percentCompleted.text = percentCompletedStr
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       // print("selected")
    }
    
    public func updateValues(cellNo: String, title: String){
        
    }

}
