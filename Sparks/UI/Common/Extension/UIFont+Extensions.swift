//
//  UIFont+Extensions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 5/18/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

enum FontStyle : String {
    case bold = "Bold"
    case book = "Book"
    case eight = "Eight"
    case extraBold = "ExtraBold"
    case extraLight = "ExtraLight"
    case four = "Four"
    case hair = "Hair"
    case heavy = "Heavy"
    case light = "Light"
    case medium = "Medium"
    case regular = "Regular"
    case semiBold = "SemiBold"
    case thin = "Thin"
    case two = "Two"
    case ultraLight = "UltraLight"
}

extension UIFont {
    class func font(for size: CGFloat = 17, style: FontStyle = .regular) -> UIFont {
        guard let font = UIFont(name: "FiraGO-\(style.rawValue)", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    class var regular17: UIFont { return font() }
    class var medium17: UIFont { return font(style: .medium) }
}
