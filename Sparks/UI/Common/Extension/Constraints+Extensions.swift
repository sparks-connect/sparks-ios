
//
//  Constraint+Extensions.swift
//  SpaceCore
//
//  Created by Nika Samadashvili on 4/9/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

extension UIButton {
    
    @IBInspectable public var adjustContentEdgeInsetsToFitDevice : Bool {
        get { return false }
        set {
            self.contentEdgeInsets.top *= Consts.screenFactor
            self.contentEdgeInsets.left *= Consts.screenFactor
            self.contentEdgeInsets.bottom *= Consts.screenFactor
            self.contentEdgeInsets.right *= Consts.screenFactor
        }
    }
    
    @IBInspectable public var adjustImageEdgeInsetsToFitDevice : Bool {
        get { return false }
        set {
            self.imageEdgeInsets.top *= Consts.screenFactor
            self.imageEdgeInsets.left *= Consts.screenFactor
            self.imageEdgeInsets.bottom *= Consts.screenFactor
            self.imageEdgeInsets.right *= Consts.screenFactor
        }
    }
    
    @IBInspectable public var adjustTitleEdgeInsetsToFitDevice : Bool {
        get { return false }
        set {
            self.titleEdgeInsets.top *= Consts.screenFactor
            self.titleEdgeInsets.left *= Consts.screenFactor
            self.titleEdgeInsets.bottom *= Consts.screenFactor
            self.titleEdgeInsets.right *= Consts.screenFactor
        }
    }
    
    @IBInspectable public var shouldAdjustFontSizeToFitDevice : Bool { get { return false } set { if(newValue) { self.adjustsFontSizeToFitDevice() } } }
    
    public func adjustsFontSizeToFitDevice() {
        self.titleLabel?.adjustsFontSizeToFitDevice()
    }
    
}

extension UITextField {
    
    @IBInspectable public var shouldAdjustFontSizeToFitDevice : Bool { get { return false } set { if(newValue) { self.adjustsFontSizeToFitDevice() } } }
    
    public func adjustsFontSizeToFitDevice() {
        if let f = self.font {
            self.font = UIFont(name: f.fontName, size: f.pointSize * Consts.screenFactor)
        }
    }
    
}

extension UILabel {
    @IBInspectable public var shouldAdjustFontSizeToFitDevice : Bool { get { return false } set { if(newValue) { self.adjustsFontSizeToFitDevice() } } }
    
    public func adjustsFontSizeToFitDevice() {
        if let f = self.font {
            self.font = UIFont(name: f.fontName, size: f.pointSize * Consts.screenFactor)
        }
    }
}

extension NSLayoutConstraint {
    @IBInspectable public var shouldAdjustConstantToFitDevice : Bool { get { return false } set { if(newValue) { self.constant *= Consts.screenFactor } } }
}
