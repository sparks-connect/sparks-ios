//
//  CardBottomAdView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class CardBottomAdViewCfg: CardContentBaseViewCfg {
    var adObject: CardAd!
    init(adObject: CardAd) {
        self.adObject = adObject
    }
}

class CardBottomAdView: CardContentBaseView {
    
    lazy private(set) var lblTitle : UILabel = {
        let label = UILabel()
        label.textColor = Color.lightPurple.uiColor
        label.font = Font.medium.uiFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private(set) var lblDescription : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = Font.bold.uiFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private(set) var iconView : CircleImageView = {
        let iv = CircleImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
 
    lazy private(set) var optionsButton : UIButton = {
        let button = UIButton()
        button.setImage(Image.options.uiImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func configure() {
        layout()
    }
    
    private func layout(){
        addSubview(iconView)
        iconView.snp.makeConstraints({
            $0.centerY.equalTo(self.snp.centerY)
            $0.left.equalTo(24)
            $0.width.height.equalTo(60)
        })
        
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints({
            $0.centerY.equalTo(iconView.snp.centerY).offset(-10)
            $0.left.equalTo(iconView.snp.right).inset(-16)
        })
        
        addSubview(lblDescription)
        lblDescription.snp.makeConstraints({
            $0.centerY.equalTo(iconView.snp.centerY).offset(10)
            $0.left.equalTo(iconView.snp.right).inset(-16)
        })
        
        addSubview(optionsButton)
        optionsButton.snp.makeConstraints({
            $0.centerY.equalTo(self.snp.centerY)
            $0.right.equalTo(-24)
            $0.width.equalTo(24)
        })
    }
    
    override func setup(with config: CardContentBaseViewCfg?) {
        if let cfg = config as? CardBottomAdViewCfg {
            iconView.setImageFromUrl(cfg.adObject.imageUrl)
            lblTitle.text = cfg.adObject.title
            lblDescription.text = cfg.adObject.descr
        }
    }

}
