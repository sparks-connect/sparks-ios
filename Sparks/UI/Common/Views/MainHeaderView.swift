//
//  MainHeaderView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SDWebImage

protocol MainHeaderViewDelegate: class {
    func didTapOnActionButton()
}

class MainHeaderView: BaseView {
    
    var imageUrl: String? {
        didSet {
            guard let _url = imageUrl else { return }
            self.userSettingsButton.sd_setImage(
                with: URL(string: _url),
                for: .normal,
                placeholderImage: self.image,
                options: SDWebImageOptions.refreshCached,
                completed: nil
            )
        }
    }
    
    var image: UIImage? {
        didSet {
            self.userSettingsButton.setImage(self.image, for: .normal)
        }
    }
    
    var title: String = "" {
        didSet {
            self.profileLabel.text = title
        }
    }
    
    weak var delegate: MainHeaderViewDelegate?
    
    lazy private(set) var profileLabel : Label = {
        let view = Label()
        view.textColor = .white
        view.font = Font.bold.uiFont(ofSize: 22)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private(set) var userSettingsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Image.userSettings.uiImage, for: .normal)
        button.addTarget(self, action: #selector(didTapOnActionButton), for: .touchUpInside)
        return button
    }()
    
    override func configure() {
        layout()
    }
    
    //MARK: Private functinos
    func layout(){
        addSubview(profileLabel)
        addSubview(userSettingsButton)
        setUpConstraints()
    }
    
    func setUpConstraints() {
        profileLabel.snp.makeConstraints({
            $0.top.equalTo(0)
            $0.right.left.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        })

        userSettingsButton.snp.makeConstraints({
            $0.centerY.equalTo(profileLabel.snp.centerY)
            $0.right.equalToSuperview().inset(30)
            $0.height.equalTo(30)
            $0.width.equalTo(30)
        })
        userSettingsButton.contentMode = .scaleAspectFill
        userSettingsButton.layer.cornerRadius = 15
        userSettingsButton.clipsToBounds = true
    }
    
    @objc private func didTapOnActionButton() {
        self.delegate?.didTapOnActionButton()
    }
    
}

class MainNavigationView: MainHeaderView {
    
    override func setUpConstraints() {
        profileLabel.snp.makeConstraints({
            $0.top.equalTo(0)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        })

        userSettingsButton.snp.makeConstraints({
            $0.centerY.equalTo(profileLabel.snp.centerY)
            $0.left.equalToSuperview().inset(30)
            $0.height.equalTo(30)
            $0.width.equalTo(30)
        })
        userSettingsButton.contentMode = .scaleAspectFill
        userSettingsButton.layer.cornerRadius = 15
        userSettingsButton.clipsToBounds = true
        userSettingsButton.setImage(Image.back.uiImage, for: .normal)
    }
    
}
