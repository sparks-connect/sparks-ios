//
//  UIColor+Ext.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/10/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit


extension UIColor {    
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 0xFF, "Invalid red component")
        assert(green >= 0 && green <= 0xFF, "Invalid green component")
        assert(blue >= 0 && blue <= 0xFF, "Invalid blue component")
        assert(alpha >= 0.0 && alpha <= 1.0, "Invalid alpha component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        assert(rgb >= 0 && rgb <= 0xFFFFFF, "Invalid rgb component")
        
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
    
    convenience init(rgb: String, alpha: CGFloat = 1.0) {
        assert(rgb.count >= 6 && rgb.count <= 7, "Invalid rgb component")
        
        var hex = rgb.uppercased()
        
        if hex.count > 6 {
            hex.remove(at: hex.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        self.init(rgb: Int(rgbValue), alpha: alpha)
    }
    
    convenience init(rgba: Int) {
        assert(rgba >= 0 && rgba <= 0xFFFFFFFF, "Invalid rgba component")
        
        self.init(
            red: (rgba >> 24) & 0xFF,
            green: (rgba >> 16) & 0xFF,
            blue: (rgba >> 8) & 0xFF,
            alpha: CGFloat(rgba & 0xFF) / 255.0
        )
    }
    
    convenience init(rgba: String) {
        assert(rgba.count >= 8 && rgba.count <= 9, "Invalid rgba component")
        
        var hex = rgba.uppercased()
        
        if hex.count > 8 {
            hex.remove(at: hex.startIndex)
        }
        
        var rgbaValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbaValue)
        
        self.init(rgba: Int(rgbaValue))
    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    convenience init(xColor: UIColor, yColor: UIColor, percentage: CGFloat = 0.5) {
        assert(percentage >= 0.0 && percentage <= 1.0, "Invalid percentage component")
        
        var redX: CGFloat = 0.0, greenX: CGFloat = 0.0, blueX: CGFloat = 0.0, alphaX: CGFloat = 1.0
        var redY: CGFloat = 0.0, greenY: CGFloat = 0.0, blueY: CGFloat = 0.0, alphaY: CGFloat = 1.0
        
        xColor.getRed(&redX, green: &greenX, blue: &blueX, alpha: &alphaX)
        yColor.getRed(&redY, green: &greenY, blue: &blueY, alpha: &alphaY)
        
        let red = redX + percentage * (redY - redX)
        let green = greenX + percentage * (greenY - greenX)
        let blue = blueX + percentage * (blueY - blueX)
        let alpha = alphaX + percentage * (alphaY - alphaX)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(colors: [UIColor], percentage: CGFloat = 0.5) {
        assert(colors.count >= 0, "Invalid colors component")
        assert(percentage >= 0.0 && percentage <= 1.0, "Invalid percentage component")
        
        let percentage = percentage * CGFloat(colors.count - 1)
        
        let xColor = colors[Int(floor(percentage))]
        let yColor = colors[Int(ceil(percentage))]
        
        self.init(xColor: xColor, yColor: yColor, percentage: CGFloat(percentage - floor(percentage)))
    }
    
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        
        return String(format: "#%06x", rgb)
    }
    
    var hsba:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    static var messageSender : UIColor {
        return UIColor(red: 0.488, green: 0.182, blue: 0.958, alpha: 1.0)
    }
    
    static var messageReceiver : UIColor {
        return UIColor(red: 0.145, green: 0.124, blue: 0.168, alpha: 1.0)
        
    }
    
}
