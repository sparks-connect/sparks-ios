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
        view.textAlignment = .left
        view.textColor = .white
        
        return view
    }()
    
    private let descriptionLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 14, weight:.medium)
        view.textColor = Color.fadedPurple.uiColor
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private let imageView : ImageView = {
        let view = ImageView()
        view.contentMode = .scaleAspectFill
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
        self.imageView.image = OnboardingPageDataSource.items[index].image
    }
    
    private func setupLayout() {
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.right.left.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        addSubview(titeLabel)
        titeLabel.snp.makeConstraints{
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.left.equalTo(16)
            $0.right.equalTo(-16)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints{
            $0.top.equalTo(titeLabel.snp.bottom).offset(8)
            $0.left.equalTo(titeLabel.snp.left)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

