//
//  BasePopupController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 10/24/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit


// override popupInsets to change up popup height
// add subviews to popupView to keep it cool

class BasePopupController: BaseController {
    
    var popupInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 180, left: 30, bottom: 180, right: 30)
    }
    
    let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - private parameters
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
  
    // MARK: - life cycle
    override func configure() {
        super.configure()
        self.view.backgroundColor = .clear
        layout()
      
    }
    
    // MARK: - private methds
    private func layout(){
        self.view.addSubview(backgroundView)
        backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.view.addSubview(popupView)
        popupView.centerYAnchor.constraint(equalTo: self.backgroundView.centerYAnchor).isActive = true
        popupView.centerXAnchor.constraint(equalTo: self.backgroundView.centerXAnchor).isActive = true
        popupView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: popupInsets.top).isActive = true
        popupView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -popupInsets.bottom).isActive = true
        popupView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: popupInsets.left).isActive = true
        popupView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -popupInsets.right).isActive = true
    }
    
}
