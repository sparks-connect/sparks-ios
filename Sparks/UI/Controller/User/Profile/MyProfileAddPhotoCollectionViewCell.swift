//
//  MyProfileAddPhotoCollectionViewCell.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

class MyProfileAddPhotoCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "plus")
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let label: Label = {
        let view = Label()
        view.textColor = .white
        view.font = UIFont.font(for: 17, style: .bold)
        view.textAlignment = .center
        view.text = "Add photo"
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalTo(imageView.snp.height)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
}
