//
//  DateFormatter+Message.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/10/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

extension DateFormatter {
    func bodyString(from message: Message) -> String {
        doesRelativeDateFormatting = false
        dateFormat = "h:mm a"
        
        return string(from: message.sentDate)
    }
    
    func headerString(from message: Message) -> String {
        switch true {
        case Calendar.current.isDateInToday(message.sentDate) || Calendar.current.isDateInYesterday(message.sentDate):
            doesRelativeDateFormatting = true
            dateStyle = .short
            timeStyle = .short
        case Calendar.current.isDate(message.sentDate, equalTo: Date(), toGranularity: .weekOfYear):
            dateFormat = "EEEE h:mm a"
        case Calendar.current.isDate(message.sentDate, equalTo: Date(), toGranularity: .year):
            dateFormat = "E, d MMM, h:mm a"
        default:
            dateFormat = "MMM d, yyyy, h:mm a"
        }
        
        return string(from: message.sentDate)
    }
    
    func customFormattedString(from date: Date, format: String = "MMM d, yyyy") -> String {
        dateFormat = format
        return string(from: date)
    }
}
