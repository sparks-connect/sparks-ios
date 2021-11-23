//
//  SettingsCell.swift
//  Sparks
//
//  Created by George Vashakidze on 6/6/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class SettingsCell: TableViewCell {
    
    override var reuseIdentifier: String? { return "SettingsCell" }

    lazy private var separatorView: UIView = {
        let view = UIImageView()
        view.backgroundColor = UIColor(hex: "#F0F0F0").withAlphaComponent(0.05)
        return view
    }()
    
    lazy private var setttingsImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .white
        return view
    }()
    
    lazy private var titleLabel: Label = {
        let view = Label()
        view.font = Font.bold.uiFont(ofSize: 16)
        view.textColor = .white
        return view
    }()
    
    lazy private var subTitleLabel: Label = {
        let view = Label()
        view.font = Font.medium.uiFont(ofSize: 12)
        view.textColor = Color.lightPurple.uiColor
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setttingsImageView.image = nil
        titleLabel.text = nil
        subTitleLabel.text = nil
    }
    
    override func configure(parameter: TableViewCellParameter?, delegate: TableViewCellDelegate?) {
        super.configure(parameter: parameter, delegate: delegate)
        guard let settingsItem = parameter as? SettingsItem else { return }
        
        self.setttingsImageView.image = settingsItem.settingItemImage()
        self.titleLabel.text = settingsItem.title
        self.subTitleLabel.text = settingsItem.subTitle
    }
    
    override func setup() {
        super.setup()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(setttingsImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subTitleLabel)
        self.contentView.addSubview(separatorView)
        
        setttingsImageView.snp.makeConstraints({
            $0.width.height.equalTo(32)
            $0.left.equalTo(contentView.snp.left).offset(24)
            $0.centerY.equalTo(contentView.snp.centerY)
        })
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(setttingsImageView.snp.top).offset(-2)
            $0.left.equalTo(setttingsImageView.snp.right).offset(24)
        })
        
        subTitleLabel.snp.makeConstraints({
            $0.bottom.equalTo(setttingsImageView.snp.bottom).offset(2)
            $0.left.equalTo(setttingsImageView.snp.right).offset(24)
        })
        
        separatorView.snp.makeConstraints({
            $0.bottom.equalTo(contentView.snp.bottom).offset(0)
            $0.left.equalTo(subTitleLabel.snp.left).offset(0)
            $0.right.equalTo(contentView.snp.right).offset(-24)
            $0.height.equalTo(1)
        })
    }    
}
