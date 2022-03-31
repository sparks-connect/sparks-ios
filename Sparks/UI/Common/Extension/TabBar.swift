//
//  TabBar.swift
//  Sparks
//
//  Created by Adroit Jimmy on 27/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit
class CenterView: UIView {
    
    // MARK: - Variables
    public var didTapButton: (() -> ())?
    
    public lazy var middleButton: UIButton! = {
        let middleButton = UIButton()
        middleButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_plus")!
        middleButton.setImage(image, for: .normal)
        middleButton.backgroundColor = Color.primary.uiColor
        middleButton.tintColor = .white
        middleButton.clipsToBounds = false
        middleButton.layer.cornerRadius = 27
        middleButton.addTarget(self, action: #selector(self.middleButtonAction), for: .touchUpInside)
        return middleButton
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.clipsToBounds = false
        self.addSubview(middleButton)
        middleButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.layer.shadowColor = UIColor.darkText.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        middleButton.center = CGPoint(x: frame.width / 2, y: -5)
    }
    
    // MARK: - Actions
    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) { return true }
        for subview in subviews {
            let subviewPoint = subview.convert(point, from: self)
            if subview.point(inside: subviewPoint, with: event) { return true }
        }
        return false
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return nil
    }

}

extension UITabBar {

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?{
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return nil
    }
}
