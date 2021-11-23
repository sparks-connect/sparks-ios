//
//  CardTopTitleViewWithTags.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

final class CardTopTitleViewWithTagsCfg: CardContentBaseViewCfg {
    let id: String
    let createDate: Date
    let title: String
    let tags: [CardTag]
    
    init(id: String, createDate: Date, title: String, tags: [CardTag]) {
        self.id = id
        self.createDate = createDate
        self.title = title
        self.tags = tags
    }
}

final class CardTopTitleViewWithTags: CardContentBaseView {
    
    lazy private(set) var dateLabel : UILabel = {
        let label = UILabel()
        label.textColor = Color.lightPurple.uiColor
        label.font = Font.regular.uiFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private(set) var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = Font.bold.uiFont(ofSize: 24)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    override func configure() {
        layout()
    }
    
    private func layout(){
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints({
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(32)
            $0.right.left.equalToSuperview().inset(32)
            $0.height.equalTo(12)
        })

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.right.left.equalToSuperview().inset(32)
        })
    }
    
    override func setup(with config: CardContentBaseViewCfg?) {
        guard let cfg = config as? CardTopTitleViewWithTagsCfg else { return }
        dateLabel.text = cfg.createDate.toString("MMM d, h:mm a", localeIdentifier: "en_US")
        bottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        
        if cfg.title.count > 50 {
            bottomConstraint?.isActive = true
        } else {
            bottomConstraint?.isActive = false
        }
        
        titleLabel.text = cfg.title
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.sizeToFit()
    }
}
