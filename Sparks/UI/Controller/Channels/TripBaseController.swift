//
//  TripBaseController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 27/01/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripBaseController: PageBaseController {
    
    var titleText: String {
        return "Where you are going ?"
    }
    
    var buttonText: String{
        return "Next"
    }
    
    var buttonColor: UIColor{
        return Color.purple.uiColor
    }
    
    private lazy var titeLabel: Label = {
        let lbl = Label()
        lbl.textAlignment = .center
        lbl.font =  UIFont.systemFont(ofSize: 30, weight:.bold)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.text = titleText
        return lbl
    }()
    
    private lazy var nextButton: PrimaryButton = {
        let btn = PrimaryButton()
        btn.setTitle(buttonText, for: .normal)
        btn.addTarget(self, action: #selector(nextClicked), for: .touchUpInside)
        btn.layer.cornerRadius = 32
        btn.backgroundColor = buttonColor
        return btn
    }()
    
    override func configure() {
        super.configure()
        layout()
    }
    
    func layout(){
        self.view.addSubview(titeLabel)
        titeLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(16)
            $0.left.equalTo(32)
            $0.right.equalTo(-32)
        }
        
        self.view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.left.equalToSuperview().inset(32)
            $0.right.equalToSuperview().inset(32)
            $0.height.equalTo(64)
        }
    }
    
    @objc func nextClicked(){
        
    }
}
