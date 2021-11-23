//
//  ProfilePhotoAddButton.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 8/1/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class ProfilePhotoAddButton: UIControl {
    
    private(set) var imageIsSet: Bool = false {
        didSet {
            self.sendActions(for: .valueChanged)
        }
    }
    
    var imageURL: String? {
        didSet {
            self.imageIsSet = false
            self.imageView.setImageFromUrl(imageURL) { (image, error) in
                self.imageIsSet = error == nil && image != nil
            }
        }
    }
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_profile_photo_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var imageView: ImageView = {
        let imageView = ImageView()
        return imageView
    }()
    
    private lazy var addImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_plus_circle")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Color.purple.uiColor
        return imageView
    }()
    
    private lazy var addIconContainer: UIView = {
        let view = CircleCornerView()
        view.backgroundColor = .white
        
        view.addSubview(addImageView)
        addImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.6)
        }
        return view
    }()
    
    private lazy var iconContainer: UIView = {
        let view = CircleCornerView()
        view.backgroundColor = Color.lighterBackground.uiColor
        
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.4)
        }
        
        view.addSubview(addIconContainer)
        addIconContainer.snp.makeConstraints { (make) in
            make.top.equalTo(-2)
            make.right.equalTo(2)
            make.width.height.equalTo(20)
        }
        return view
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.bold.uiFont(ofSize: 14)
        view.textColor = Color.lighterBackground.uiColor
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        view.text = "Add photo"
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 32
        self.backgroundColor = Color.lightBackground.uiColor
        self.addSubview(iconContainer)
        self.addSubview(descriptionLabel)
        self.addSubview(imageView)
        
        iconContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.3)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconContainer.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clicked(sender:))))
    }
    
    @objc private func clicked(sender: UITapGestureRecognizer) {
        self.sendActions(for: .touchUpInside)
    }
}
