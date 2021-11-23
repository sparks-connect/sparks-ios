//
//  Font.swift
//  Sparks
//
//  Created by George Vashakidze on 3/22/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

enum Font: String {

    case black = "SFProDisplay-Black"
    case blackItalic = "SFProDisplay-BlackItalic"
    case bold = "SFProDisplay-Bold"
    case semiBold = "SFProDisplay-Semibold"
    case semiBoldItalic = "SFProDisplay-SemiboldItalic"
    case boldItalic = "SFProDisplay-BoldItalic"
    case heavy = "SFProDisplay-Heavy"
    case heavyItalic = "SFProDisplay-HeavyItalic"
    case light = "SFProDisplay-Light"
    case lightItalic = "SFProDisplay-LightItalic"
    case medium = "SFProDisplay-Medium"
    case mediumItalic = "SFProDisplay-MediumItalic"
    case regular = "SFProDisplay-Regular"
    case regularItalic = "SFProDisplay-RegularItalic"
    case thin = "SFProDisplay-Thin"
    case thinItalic = "SFProDisplay-ThinItalic"
    case ultraLight = "SFProDisplay-Ultralight"
    case ultraLightItalic = "SFProDisplay-UltralightItalic"
    
    func uiFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}
