//
//  PageCell.swift
//  Sparks
//
//  Created by Nika Samadashvili on 3/1/20.
//  Copyright © 2020 Sparks. All rights reserved.
//


import UIKit
import SnapKit

class PageCell: UICollectionViewCell {
    
    private let titeLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 32, weight:.bold)
        view.numberOfLines = 0
        view.textColor = .white
        return view
    }()
    
    private let descriptionLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 14, weight:.medium)
        view.numberOfLines = 0
        view.textColor = Color.lightPurple.uiColor
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.background.uiColor
        setupLayout()
    }
    
    func setupWith(index: Int) {
        self.titeLabel.text = OnboardingPageDataSource.items[index].title
        self.descriptionLabel.text = OnboardingPageDataSource.items[index].desc
    }
    
    private func setupLayout() {
        let offset = UIScreen.main.bounds.size.height * 0.06
        addSubview(titeLabel)
        titeLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(offset)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints{
            $0.top.equalTo(titeLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

