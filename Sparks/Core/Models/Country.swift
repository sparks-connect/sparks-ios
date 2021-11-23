//
//  Country.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/17/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

class Country: Codable, TableViewCellParameter {
    private(set) var shortName: String = ""
    private(set) var name: String = ""
    private(set) var code: String = ""
    private(set) var emoji: String = ""
    
    static var defaultCountry: Country {
        let country = Country()
        country.shortName = "GE"
        country.name = "Georgia"
        country.code = "+995"
        country.emoji = "🇬🇪"
        return country
    }
    
    var emojiWithCode: String {
        return "\(emoji) \(code)"
    }
}
