//
//  Color.swift
//  Sparks
//
//  Created by George Vashakidze on 3/22/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

enum Color: String {

    //case primaryBg = "#19181F"
    case primary = "#FAC800"
    case lightGray = "#d3d3d3"
    case lightGray2 = "#f0f0f0"
    case inkBlue = "#150D4C"
    case purple = "#723CEB"
    case lightPurple = "#8A7E9A"
    case fadedPurple = "#8D7D9C"
    case fadedBackground = "#393342"
    case fadedLighter = "#4A4355"
    case background = "#19181F"
    case lightBackground = "#25202B"
    case lighterBackground = "#574F62"
    case gray = "#6B6B6B"
    case red = "#E73B35"
    case buttonColor = "#24202A"
    case green = "#5AC500"
    case fb = "#1A76F2"
    case google = "#EB4131"

    var uiColor: UIColor {
        return UIColor(rgb: rawValue)
    }

    var cgColor: CGColor {
        return uiColor.cgColor
    }

    func uiColorWithAlpha(_ alpha: CGFloat) -> UIColor {
        return UIColor(rgb: rawValue, alpha: alpha)
    }
    
}
