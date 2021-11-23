//
//  CardTopTimerView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class CardTopTimerViewCfg: CardContentBaseViewCfg {
    
    var date: Date!
    
    init(date: Date) {
        self.date = date
    }
}

class CardTopTimerView: CardContentBaseView {
    
    lazy private(set) var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = Font.bold.uiFont(ofSize: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "You are out of swipes"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private(set) var subTitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = Color.lightPurple.uiColor
        label.font = Font.regular.uiFont(ofSize: 14)
        label.text = "Get more swipes in:"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private(set) var timerLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = Font.bold.uiFont(ofSize: 48)
        label.numberOfLines = 0
        label.text = "16:20:12"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func configure() {
        layout()
    }
    
    private func layout(){
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(48)
            $0.centerX.equalTo(self.snp.centerX)
        })
        
        addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalTo(self.snp.centerX)
        })

        addSubview(timerLabel)
        timerLabel.snp.makeConstraints({
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(16)
            $0.centerX.equalTo(self.snp.centerX)
        })
    }
    
    override func setup(with config: CardContentBaseViewCfg?) {
        if let cfg = config as? CardTopTimerViewCfg {
            
        }
    }
}
