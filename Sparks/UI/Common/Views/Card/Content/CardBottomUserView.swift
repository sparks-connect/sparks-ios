//
//  CardBottomUserView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SDWebImage

class CardBottomUserViewCfg: CardContentBaseViewCfg {
    var channel: Channel!
    init(channel: Channel) {
        self.channel = channel
    }
}

class CardBottomUserView: CardContentBaseView {
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    lazy private(set) var lblDistance : UILabel = {
        let label = UILabel()
        label.textColor = Color.lightPurple.uiColor
        label.font = Font.medium.uiFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private(set) var lblUsername : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = Font.bold.uiFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private(set) var userImageView : CircleImageView = {
        let iv = CircleImageView()
        iv.image = Image.userPlaceholder.uiImage
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy private(set) var userApprovedImageView : UIImageView = {
        let iv = UIImageView()
        iv.image = Image.approvedUser.uiImage
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy private(set) var userLockedImageView : UIImageView = {
        let iv = UIImageView()
        iv.image = Image.locked.uiImage
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
        context = CIContext()
        currentFilter = CIFilter(name: "CIGaussianBlur")
        
        layout()
    }
    
    private func layout(){
        addSubview(userImageView)
        userImageView.snp.makeConstraints({
            $0.centerY.equalTo(self.snp.centerY)
            $0.left.equalTo(24)
            $0.width.height.equalTo(60)
        })
        
        addSubview(lblUsername)
        lblUsername.snp.makeConstraints({
            $0.centerY.equalTo(userImageView.snp.centerY).offset(-10)
            $0.left.equalTo(userImageView.snp.right).inset(-16)
        })
        
        addSubview(lblDistance)
        lblDistance.snp.makeConstraints({
            $0.centerY.equalTo(userImageView.snp.centerY).offset(10)
            $0.left.equalTo(userImageView.snp.right).inset(-16)
        })
        
        addSubview(userApprovedImageView)
        userApprovedImageView.snp.makeConstraints({
            $0.centerY.equalTo(lblUsername.snp.centerY)
            $0.left.equalTo(lblUsername.snp.right).inset(-8)
            $0.width.equalTo(14)
        })
        
        addSubview(userLockedImageView)
        userLockedImageView.snp.makeConstraints({
            $0.centerY.equalTo(userImageView.snp.centerY)
            $0.centerX.equalTo(userImageView.snp.centerX)
        })
        
        addSubview(optionsButton)
        optionsButton.snp.makeConstraints({
            $0.centerY.equalTo(self.snp.centerY)
            $0.right.equalTo(-24)
            $0.width.equalTo(24)
        })
    }
    
    override func setup(with config: CardContentBaseViewCfg?) {
        if let cfg = config as? CardBottomUserViewCfg {
            
            lblUsername.text = "\(cfg.channel.otherUsers.first?.displayName ?? ""), \(cfg.channel.otherUsers.first?.ageYear ?? 0)"
            lblDistance.text = "\(cfg.channel.distance) away"
            
            guard let imageUrl = cfg.channel.otherUsers.first?.photoUrl, let url = URL(string: imageUrl) else {
                return
            }
            
            SDWebImageDownloader.shared.downloadImage(with: url) { (img, _, _, _) in
                img?.blurred(filterValue: 20, completion: {[weak self] (image) in
                    DispatchQueue.main.async {[weak self] in
                        self?.userImageView.image = image
                    }
                })
            }
        }
    }
}
