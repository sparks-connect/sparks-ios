//
//  EmptyListView.swift
//  Sparks
//
//  Created by Nika Samadashvili on 8/30/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit
import SnapKit


class ChannelsEmptyListView : UIView {
    
    var actionButton: UIButton? = {
        let view = UIButton()
        view.backgroundColor = Color.purple.uiColor
        view.setTitleColor(.lightGray, for: .highlighted)
        view.setTitle("send new message", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.titleLabel?.textColor = .white
        view.layer.cornerRadius = 15
        return view
    }()
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = #imageLiteral(resourceName: "noChannelsIcon")
        return view
    }()
    
    var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 32, weight:.bold)
        view.text = "No Active \n Conversations"
        return view
    }()
    
    var describtionLabel: UILabel = {
        let view = UILabel()
        view.textColor = Color.fadedPurple.uiColor
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = "inbox is empty, messages appear \n here when you match with someone"
        view.font = .systemFont(ofSize: 14, weight: .light)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func layout(){
        self.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.4)
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(describtionLabel)
        describtionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(actionButton!)
        actionButton?.snp.makeConstraints({
            $0.bottom.equalToSuperview()
            $0.left.right.equalToSuperview().inset(100)
            $0.height.equalTo(60)
        })
        
        
    }
    
    
}
