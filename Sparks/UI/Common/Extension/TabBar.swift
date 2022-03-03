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
        middleButton.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.4117647059, blue: 0.3803921569, alpha: 1)
        middleButton.tintColor = .white
        middleButton.layer.cornerRadius = 34
        middleButton.clipsToBounds = false
        middleButton.addTarget(self, action: #selector(self.middleButtonAction), for: .touchUpInside)
        return middleButton
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.clipsToBounds = false
        self.addSubview(middleButton)
        middleButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(10)
        }
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.4
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
}

extension UITabBar {
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
