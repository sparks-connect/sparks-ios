
//
//  AcceptCell.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/5/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import MessageKit

open class RecipientDeclineCell : AbstractCustomCell {
    
    // MARK: - Views
    private let outterView : UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightBackground.uiColor
        view.layer.cornerRadius = 15
        return view
    }()
    
    
    private let titleLabel : Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .white
        view.numberOfLines = 0
        return view
    }()
    
    private let lockImage : CircleImageView = {
        let view = CircleImageView()
        view.image = #imageLiteral(resourceName: "lock")
        
        return view
    }()
    
    // MARK: - configurator
    
    
     override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        
        let senderName = message.sender.displayName
        titleLabel.text = "\(senderName) Declined Request"
        
        layout()
    }
    
    // MARK: - Constructors
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func layout(){
        addSubview(outterView)
        outterView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(4)
            $0.width.equalTo(250)
            $0.height.equalTo(66)
        }
        
        outterView.addSubview(lockImage)
        lockImage.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(28)
        }
        
        outterView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(lockImage.snp.right).inset(-16)
            $0.right.equalToSuperview().inset(16)
        }
        
    }
}

