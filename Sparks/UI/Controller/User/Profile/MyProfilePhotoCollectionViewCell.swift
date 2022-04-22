//
//  MyProfilePhotoCollectionViewCell.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 05.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

class MyProfilePhotoCollectionViewCell: UICollectionViewCell {
    
    private var lastError: Error?
    
    private let imageView: ImageView = {
        let imageView = ImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let smallImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.image = #imageLiteral(resourceName: "ic_settings_refferal_link")
        imageView.tintColor = .lightGray
        imageView.alpha = 0.3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.borderColor = Color.fadedPurple.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageViewCheck: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "check"))
        view.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(smallImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(containerView)
        containerView.addSubview(imageViewCheck)
        contentView.addSubview(borderView)
        
        imageView.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
        containerView.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
        imageViewCheck.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        smallImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.4)
        }
        
        borderView.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        imageView.image = nil
        smallImageView.isHidden = true
    }
    
    func setup(url: URL?, isSelected: Bool = false) {
        self.isSelected = isSelected
        self.updateUI()
        self.imageView.setImageFromUrl(url?.absoluteString, placeholderImg: nil) {[weak self] image, error in
            self?.smallImageView.isHidden = error == nil
            self?.smallImageView.isHidden = error == nil && self?.imageView.image != nil
            self?.lastError = error
        }
    }
    
    private func updateUI() {
        self.containerView.isHidden = !self.isSelected
        borderView.isHidden = !self.isSelected
    }
}

