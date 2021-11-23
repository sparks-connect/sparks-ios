//
//  RadialGradientLayer.swift
//  Sparks
//
//  Created by Nika Samadashvili on 11/15/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit

class CircularGradientView: UIView {
    let upperfiller: UIView = {
        let view = UIView()
        return view
    }()
    
    let midfiller: UIView = {
        let view = UIView()
        return view
    }()
    
    let lowerfiller: UIView = {
        let view = UIView()
        return view
    }()
    
    var fadedBackgroudColor: UIColor?
    
    private lazy var pulse: CAGradientLayer = {
        let l = CAGradientLayer()
        l.type = .radial
        if let backgroundColor = self.fadedBackgroudColor {
            l.colors = [backgroundColor.withAlphaComponent(0.5).cgColor,
                        backgroundColor.withAlphaComponent(1.0).cgColor]
        }
        l.locations = [0.5 , 1.0]
        l.startPoint = CGPoint(x: 0.5, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(l)
        self.backgroundColor = .clear
        return l
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        upperfiller.backgroundColor = fadedBackgroudColor
        midfiller.backgroundColor = fadedBackgroudColor?.withAlphaComponent(0.9)
        lowerfiller.backgroundColor = fadedBackgroudColor
        
        
        upperfiller.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.25 * bounds.height)
        midfiller.frame = CGRect(x: 0, y: 0.25 * bounds.height, width: bounds.width, height: 0.5 * bounds.height)
        pulse.frame = CGRect(x: 0, y: 0.25 * bounds.height, width: bounds.width, height: 0.5 * bounds.height)
        lowerfiller.frame = CGRect(x: 0, y: 0.75 * bounds.height, width: bounds.width, height: 0.25 * bounds.height)
        addSubview(lowerfiller)
        addSubview(midfiller)
        addSubview(upperfiller)
    }
    
}

