//
//  AvgProgress.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 23/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import Foundation

// This is static class for holding the table cell values of average

public class AvgProgress {
    private static var avg: Float = 0
    private static var members: Int = 0
    
    init(){}
    
    // adds a member and a value
    static func add(_ valueToAdd: Float){
        members+=1
        // rounding in order to prevent having unexpected averages generated
        // because user does not see 1/thousands' and smaller parts of values
        let valueToAdd = round(valueToAdd * 100) / 100
        avg = avg + valueToAdd
    }
    
    
    static func delete(_ numToDiff : Float){
        avg = avg - numToDiff
        members -= 1
        if (members < 0){
            print("negative avg members count, should never happen")
        }
    }
    
    static func getMembers() -> Int{
        return members
    }
    
    static func getAvg() -> Float{
       return Float(avg / Float(members))
    }
    
    
    // This method is supposed to be called every time new assessment is selected
    static func reset(){
        avg = 0
        members = 0
    }
    
}
