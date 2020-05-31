//
//  DateUtils.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 22/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import Foundation

// Date utility functions

func absSecondsBetweenTwoDates(_ date1: Date, _ date2: Date) -> Int {
    let cal = Calendar.current
    let components = cal.dateComponents([.second], from: date1, to: date2)
    let diff = components.second!
    return abs(Int(diff))
}

func absMinutesBetweenTwoDates(_ date1: Date, _ date2: Date) -> Int {
    let cal = Calendar.current
    let components = cal.dateComponents([.minute], from: date1, to: date2)
    let diff = components.minute!
    return abs(Int(diff))
}

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

func dateComponentFromDate(_ date: Date)-> DateComponents{
    let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    return comps
}

func describeSeconds(seconds: Int) -> String {
    let minutes = seconds/60
    let hoursTotal: Int = minutes / 60
    let minutesModuled: Int = minutes % 60
    let daysTotal: Int = hoursTotal / 24
    
    if (hoursTotal > 48){
       return ("\(daysTotal) Days+  Left")
    }
    
    if (hoursTotal > 24){
        return ("\(daysTotal) Day+  Left")
    }
    
    if (minutes == 0 && hoursTotal == 0 && seconds % 60 != 0) {
        return "Less Than 1 Minute Left"
    }
    
    let minutesModuledAndZeroed: String = addZeroToTimeString(hourOrMin: minutesModuled)
    let hoursZeroed: String = addZeroToTimeString(hourOrMin: hoursTotal)
    
    
  
    return ("\(hoursZeroed):\(minutesModuledAndZeroed)  Left")

}

private func addZeroToTimeString(hourOrMin: Int) -> String {
    let e = hourOrMin
    
    if (e < 10){
        return "0\(e)"
    }
    
    return ("\(e)")
}
