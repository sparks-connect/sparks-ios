//
//  GradientView.swift
//  Sparks
//
//  Created by Nika Samadashvili on 8/31/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit

class GradietView : UIView {
    
    lazy var gradientMaskLayer : CAGradientLayer = {
        let gradientMaskLayer =  CAGradientLayer()
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientMaskLayer.locations = [0.0, 0.95]
        gradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 0.95)
        
        return gradientMaskLayer
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.addSublayer(gradientMaskLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientMaskLayer.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


