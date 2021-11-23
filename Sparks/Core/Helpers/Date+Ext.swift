//
//  Date+Ext.swift
//  Sparks
//
//  Created by Nika Samadashvili on 4/9/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

extension Date {
    
    func toRelativeDateString()->String{
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" : "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" : "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" : "\(day)" + " " + "days ago"
        }else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "hour ago" : "\(hour)" + " " + "hours ago"
        }else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "\(minute)" + " " + "minute ago" : "\(minute)" + " " + "minutes ago"
        }else if let second = interval.second, second > 0 {
            return second == 1 ? "\(second)" + " " + "second ago" : "\(second)" + " " + "seconds ago"
        } else {
            return "a moment ago"
        }
    }
    
    init(milliseconds: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
}

// MARK: ########### Date ######################

func date(from str: String, formatter: DateFormatter) -> Date {
    if let dateObj = formatter.date(from: str) {
        return dateObj
    }
    
    return Date()
}

public func milliseconds(from date: Date)->Double {
    return (date.timeIntervalSince1970*1000) as Double
}

public func date(from millis: Double)->Date {
    return Date(timeIntervalSince1970: millis)
}

func milliseconds(from str: String, formatStr: DateFormatter) -> Double {
    return milliseconds(from: date(from: str, formatter: formatStr))
}

public func mill2Str(_ milliseconds: Double, format: String = "MM/dd/yy", localeIdentifier: String = Locale.current.identifier)->String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: localeIdentifier)
    let date = Date(timeIntervalSince1970: (milliseconds/1000))
    return dateFormatter.string(from: date)
}
