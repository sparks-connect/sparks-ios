//
//  CustomCell.swift
//  Sparks
//
//  Created by Nika Samadashvili on 4/17/20.
//  Copyright © 2020 Sparks. All rights reserved.
//
//


import UIKit
import MessageKit

open class RecipientRequestCell : AbstractCustomCell {
    
    // MARK: - Views
    private let outterView : UIView = {
        let view = UIView()
        view.backgroundColor = Color.purple.uiColor
        view.layer.cornerRadius = 28
        return view
    }()
    
    
    private let titleLabel : Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .white
        view.text = "Unlock request received"
        view.numberOfLines = 0
        return view
    }()

    private let lockImage : CircleImageView = {
        let view = CircleImageView()
        view.image = #imageLiteral(resourceName: "paleUnlockLogo")
        
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
                $0.left.equalToSuperview().inset(8)
                $0.top.equalToSuperview()
                $0.width.equalTo(233)
                $0.height.equalTo(56)
            }
        
        outterView.addSubview(lockImage)
        lockImage.snp.makeConstraints {
            $0.right.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(28)
        }
        
        outterView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(lockImage.snp.left).inset(-6)
           // $0.right.equalToSuperview().inset(16)
        }
    
    }
}
