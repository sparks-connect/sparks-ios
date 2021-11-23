//
//  AcceptCell.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/5/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import MessageKit

open class AcceptCell : AbstractCustomCell {
    
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
        view.text = "Congratulations! 🎉"
        return view
    }()
    
    private let descriptionLabel : Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 11)
        view.numberOfLines = 0
        view.textColor = Color.fadedPurple.uiColor
        view.text = "Your accounts are visible to each other click so see"
        return view
    }()
    
    
    private let unlockImage : CircleImageView = {
        let view = CircleImageView()
        view.image = #imageLiteral(resourceName: "unlockLogo")
        
        return view
    }()
    
    // MARK: - configurator
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {

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
            $0.left.right.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(4)
            $0.height.equalTo(102)
        }
        
        
        outterView.addSubview(unlockImage)
        unlockImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(48)
        }
        
        outterView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(unlockImage.snp.top)
            $0.left.equalTo(unlockImage.snp.right).inset(-16)
            $0.right.equalToSuperview().inset(16)
        }
        
        outterView.addSubview(descriptionLabel)
             descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).inset(-4)
            $0.left.equalTo(unlockImage.snp.right).inset(-16)
            $0.right.equalToSuperview().inset(16)
        }
    }
}

