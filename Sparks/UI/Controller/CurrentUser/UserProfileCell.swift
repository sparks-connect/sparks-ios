//
//  UserProfileCell.swift
//  Sparks
//
//  Created by George Vashakidze on 6/6/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit

class UserProfileCell: TableViewCell {
    
    override var reuseIdentifier: String? { return "UserProfileCell" }

    lazy private var separatorView: UIView = {
        let view = UIImageView()
        view.backgroundColor = UIColor(hex: "#F0F0F0").withAlphaComponent(0.05)
        return view
    }()
    
    lazy private var setttingsImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy private var titleLabel: Label = {
        let view = Label()
        return view
    }()
    
    lazy private var subTitleLabel: Label = {
        let view = Label()
        view.numberOfLines = 0
        view.lineBreakMode = .byTruncatingTail
        view.minimumScaleFactor = 0.7
        view.adjustsFontSizeToFitWidth = true
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
        guard let profileItem = parameter as? UserProfileItem else { return }
        
        self.titleLabel.text = profileItem.title
        self.subTitleLabel.text = profileItem.subTitle
        
        let style = profileItem.style.style
        
        self.titleLabel.font = style.titleFont
        self.subTitleLabel.font = style.subTitleFont
        self.titleLabel.textColor = style.titleColor
        self.subTitleLabel.textColor = style.subTitleColor
    }
    
    override func setup() {
        super.setup()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subTitleLabel)
        self.contentView.addSubview(separatorView)
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(8)
            $0.left.equalTo(24)
            $0.right.equalTo(-24)
            $0.height.equalTo(24)
        })
        
        subTitleLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-4)
            $0.left.right.equalTo(titleLabel)
        })
        
        separatorView.snp.makeConstraints({
            $0.bottom.equalTo(contentView.snp.bottom).offset(0)
            $0.left.equalTo(subTitleLabel.snp.left).offset(0)
            $0.right.equalTo(contentView.snp.right).offset(-24)
            $0.height.equalTo(1)
        })
    }
}
