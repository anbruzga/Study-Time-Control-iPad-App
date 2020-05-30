//
//  EventsController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 28/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import Foundation
import EventKitUI
import EventKit


func saveEventToCalendar(title: String, subtitle: String, notes: String, startDate: Date, setAlarm: Bool){
    
    // create event in calendar
    // @@@@@@@@@@@@@@@@@@@@@@@@@@
    // Adapted from https://stackoverflow.com/questions/28379603/how-to-add-an-event-in-the-device-calendar-using-swift
    // answer by user toofani at https://stackoverflow.com/users/1782153/toofani
    let eventStore : EKEventStore = EKEventStore()
    
    eventStore.requestAccess(to: .event) { (granted, error) in
        
        if (granted) && (error == nil) {
            print("granted \(granted)")
            print("error \(String(describing: error))")
            
            let event:EKEvent = EKEvent(eventStore: eventStore)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var titleSubtitle = title
                if (subtitle != ""){
                    titleSubtitle = title + ": " + subtitle
                }
                event.title = titleSubtitle
                
                if notes != "" {
                    event.notes = notes
                }
                else {
                    event.notes = ""
                }
                
                // -3600 == minus one hour
                let timeInterval: TimeInterval = TimeInterval(-3600)
                // This makes the event to be saved for duration of an hour
                // Starting one hour before the events' due date
                event.startDate = startDate.advanced(by: timeInterval)
                event.endDate = startDate
                
                // Optionally add alarm
                if setAlarm {
                    let alarm: EKAlarm = EKAlarm.init(absoluteDate: startDate)
                    event.addAlarm(alarm)
                }
                
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                    // self.showAlert("Saving Failure", "Failed to save event to the calendar. Error:\n  \(error)")
                }
                print("Saved Event")
                
            }
            // self.showAlert("Event Saved", "Event Saved Successfully")
        }
        else{
            //self.showAlert("Saving Failure", "failed to save event with error : \(error) or access not granted")
            print("failed to save event with error : \(String(describing: error)) or access not granted")
        }
    }
    // @@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
}



func saveReminder(title: String, notes: String, dateDue: Date, setAlarm: Bool){
    let eventStore = EKEventStore()
    
    eventStore.requestAccess(to: EKEntityType.reminder, completion:
        {(granted, error) in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(String(describing: error))")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let reminder: EKReminder = EKReminder(eventStore: eventStore)
                    reminder.title = title
                    reminder.notes = notes
                    
                    let  dueDateComp = dateComponentFromDate(dateDue)
                    reminder.dueDateComponents = dueDateComp
                    reminder.calendar = eventStore.defaultCalendarForNewReminders()
               
                    // Optionally add alarm
                    if setAlarm {
                        let alarm: EKAlarm = EKAlarm.init(absoluteDate: dateDue)
                        reminder.addAlarm(alarm)
                    }
                    
                    do {
                        try eventStore.save(reminder, commit: true)
                        
                    }catch{
                        print("Error creating and saving new reminder : \(error)")
                    }
                }
            }
            else {
                print("failed to save reminder with error : \(String(describing: error)) or access not granted")
            }
    }
    )
}
