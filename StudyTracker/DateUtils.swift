//
//  DateUtils.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 22/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import Foundation

// Date utility functions
func absHoursBetweenTwoDates(_ date1: Date, _ date2: Date) -> Int {
    let cal = Calendar.current
    let components = cal.dateComponents([.hour], from: date1, to: date2)
    let diff = components.hour!
    return abs(Int(diff))
}

func absDaysBetweenTwoDates(_ date1: Date, _ date2: Date) -> Int {
    let cal = Calendar.current
    let components = cal.dateComponents([.day], from: date1, to: date2)
    let diff = components.day!
    return abs(Int(diff))
}

func isDatePastNow(_ eventStartDate: Date) -> Bool {
    let currentDateTime = Date()
    return (currentDateTime > eventStartDate)
}

//returns [|day|, |hour|]
func absDayAndHourBetweenTwoDates(_ date1: Date, _ date2: Date) -> [Int] {
    var dayAndHour: [Int] = [-1, -1]
    dayAndHour[0] = absDaysBetweenTwoDates(date1, date2)
    dayAndHour[1] = absHoursBetweenTwoDates(date1, date2)
    return dayAndHour
}
