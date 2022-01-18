//
//  DateFormatter+Extensions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//


import Foundation

extension DateFormatter {
    
    static let defaultDateFormatter: DateFormatter = {
        let defaultDateFormatter = DateFormatter()
        defaultDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // ISO 8601 Datetime
        defaultDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return defaultDateFormatter
    }()
    
    static let defaultDateOnlyFormatter: DateFormatter = {
        let defaultDateFormatter = DateFormatter()
        defaultDateFormatter.dateFormat = "yyyy-MM-dd" // ISO 8601 Datetime
        defaultDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return defaultDateFormatter
    }()
    
    static let defaultDateFormatterWithoutSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d h:mma"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    static let defaultDateFormatterWithoutMilliseconds: DateFormatter = {
        // Sometimes the backend returns dates without milliseconds. It still is ISO 8601, I guess.
        let defaultDateFormatterWithoutMilliseconds = DateFormatter()
        defaultDateFormatterWithoutMilliseconds.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // ISO 8601 Datetime without milliseconds
        defaultDateFormatterWithoutMilliseconds.timeZone = TimeZone(secondsFromGMT: 0)
        return defaultDateFormatterWithoutMilliseconds
    }()
    
    static let shortStyleDateFormatter: DateFormatter = {
        let shortStyleDateFormatter = DateFormatter()
        shortStyleDateFormatter.dateStyle = .short
        return shortStyleDateFormatter
    }()
    
    static let modifiedShortStyleDateFormatter: DateFormatter = {
        let modifiedShortStyleDateFormatter = DateFormatter()
        modifiedShortStyleDateFormatter.dateFormat = "MM/dd/yyyy"
        return modifiedShortStyleDateFormatter
    }()
    
    static let hyphenatedShortDateFormatter: DateFormatter = {
        let birthdateDateFormatter = DateFormatter()
        birthdateDateFormatter.dateFormat = "yyyy-MM-dd" // ISO 8601 Date
        return birthdateDateFormatter
    }()
    
    static let humanizedDateFormatter: DateFormatter = {
        let birthdateDateFormatter = DateFormatter()
        birthdateDateFormatter.dateFormat = "MMMM dd, yyyy" // ISO 8601 Date
        return birthdateDateFormatter
    }()
}

