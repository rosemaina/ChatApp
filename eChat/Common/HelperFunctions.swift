//
//  HelperFunctions.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

//MARK:- Global Functions

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

//MARK:- For Calls and Chats

func dictionaryFromSnapshots(snapshots: [DocumentSnapshot]) -> [NSDictionary] {
    var allMessages: [NSDictionary] = []

    for snapshot in snapshots {
        allMessages.append(snapshot.data() as! NSDictionary)
    }
    return allMessages
}

func timeElapsed(date: Date) -> String {
    let seconds = NSDate().timeIntervalSince(date)

    var elapsed: String?

    if (seconds < 60) {
        elapsed = "Just now"

    } else if (seconds < 60 * 60) {
        let minutes = Int(seconds / 60)
        var minText = "min"

        if minutes > 1 {
            minText = "mins"
        }
        elapsed = "\(minutes) \(minText)"

    } else if (seconds < 24 * 60 * 60) {
        let hours = Int(seconds / (60 * 60))
        var hourText = "hour"
        if hours > 1 {
            hourText = "hours"
        }
        elapsed = "\(hours) \(hourText)"
    } else {
        let currentDateFormater = dateFormatter()
        currentDateFormater.dateFormat = "dd/MM/YYYY"
        
        elapsed = "\(currentDateFormater.string(from: date))"
    }

    return elapsed!
}

func formatCallTime(date: Date) -> String {
    let seconds = NSDate().timeIntervalSince(date)
    var elapsed: String?

    if (seconds < 60) {
        elapsed = "Just now"
    }  else if (seconds < 24 * 60 * 60) {

        let currentDateFormater = dateFormatter()
        currentDateFormater.dateFormat = "HH:mm"

        elapsed = "\(currentDateFormater.string(from: date))"
    } else {
        let currentDateFormater = dateFormatter()
        currentDateFormater.dateFormat = "dd/MM/YYYY"
        
        elapsed = "\(currentDateFormater.string(from: date))"
    }
    return elapsed!
}
