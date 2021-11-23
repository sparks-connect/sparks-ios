//
//  SimpleProgressView.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/19/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

enum ProgressViewDirection {
    case horizontal
    case vertical
}

class ProgressView: BaseView {
    
    private let progressView = UIView()
    private let progressView2 = UIView()
    
    var direction = ProgressViewDirection.horizontal
    var shows2Progress: Bool = false
    var color: UIColor = .clear
    var percentage: CGFloat = 0 {
        didSet {
            self.reload()
        }
    }
    
    var additionalPercentage: CGFloat? {
        didSet {
            self.reload()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            self.progressView.backgroundColor = shows2Progress ? self.tintColor.withAlphaComponent(0.5) : self.tintColor
            self.backgroundColor = self.tintColor.withAlphaComponent(0.2)
            self.progressView2.backgroundColor = shows2Progress ? self.tintColor : self.tintColor.withAlphaComponent(0.5)
        }
    }
    
    override func configure() {
        self.clipsToBounds = true
        self.addSubview(self.progressView)
        self.addSubview(self.progressView2)
    }
    
    func reload() {
        self.updatePercentage(animated: true)
        self.tintColor = color
    }
    
    private func updatePercentage(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.updatePercentage()
            }
        } else {
            self.updatePercentage()
        }
    }
    
    private func updatePercentage() {
        guard self.percentage >= 0 else { return }
        
        let progress2 = self.additionalPercentage ?? 0
        
        if self.direction == .horizontal {
            let size = self.bounds.size.width
            self.progressView.frame.size.width = self.percentage * size
            self.progressView2.frame.size.width = progress2 * size
        } else {
            let size = self.bounds.size.height
            self.progressView.frame.size.height = self.percentage * size
            self.progressView.frame.origin.y = size - self.progressView.frame.size.height
            
            self.progressView2.frame.size.height = progress2 * size
            self.progressView2.frame.origin.y = size - self.progressView.frame.size.height
        }
    }
    
    override func layoutSubviews() {
        if direction == .horizontal {
            super.layoutSubviews()
        } else {
            self.layer.cornerRadius = self.bounds.size.width / 2
        }
        
        let w = self.bounds.size.width
        let h = self.bounds.size.height
        
        if self.direction == .horizontal {
            self.progressView.frame = CGRect(x: 0, y: 0, width: 0, height: h)
            self.progressView2.frame = CGRect(x: 0, y: 0, width: 0, height: h)
        } else {
            self.progressView.frame = CGRect(x: 0, y: h, width: w, height: 0)
            self.progressView2.frame = CGRect(x: 0, y: 0, width: 0, height: h)
        }
        
        self.updatePercentage()
    }
}
