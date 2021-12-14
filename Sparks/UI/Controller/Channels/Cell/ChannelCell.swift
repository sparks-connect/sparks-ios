//
//  ChatListCell.swift
//  Sparks
//
//  Created by Nika Samadashvili on 3/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class ChannelCell: TableViewCell {
    override var reuseIdentifier: String? { return Self.description() }
    private var channel : Channel?
    
    private var profileImage: CircleUserImageView = {
        let view = CircleUserImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var personalInfoLabel : Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        view.textColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var LastMessageLabel : Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 12, weight: .light)
        view.textColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var lastMessageReceiveTimeLabel : Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        view.textColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var newSparkLabel : Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .right
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        personalInfoLabel.text = nil
        LastMessageLabel.text = nil
        profileImage.setImageFromUrl(nil)
        lastMessageReceiveTimeLabel.text = nil
    }
    
    override func configure(parameter: TableViewCellParameter?, delegate: TableViewCellDelegate?) {
        super.configure(parameter: parameter, delegate: delegate)
        guard let channel = parameter as? Channel else { return }
        guard let user = channel.otherUsers.first else { return }
        self.channel = channel
        
        personalInfoLabel.text = "\(channel.recipientDisplayName ?? ""), \(user.ageYear)"
        lastMessageReceiveTimeLabel.text = channel.lastMessageTimeHumanized
        LastMessageLabel.text = channel.text
        newSparkLabel.isHidden = channel.statusEnum != .requested
        newSparkLabel.text = channel.isMyChannel ? "Pending Spark" : "Unread Spark"
        newSparkLabel.textColor = channel.isMyChannel ? UIColor.init(hex: "#D1D100") : UIColor.init(hex: "#FAD02C")
        newSparkLabel.font = channel.isMyChannel ? UIFont.font(for: 13, style: .thin) : UIFont.font(for: 13, style: .bold)
        profileImage.set(user: nil, channel: channel)
    }
    
    override func setup(){
        self.selectionStyle = .none
        backgroundColor = Color.background.uiColor
        
        contentView.addSubview(profileImage)
        profileImage.snp.makeConstraints({
            $0.height.equalTo(40)
            $0.width.equalTo(40)
            $0.top.equalTo(16)
            $0.left.equalToSuperview().inset(16)
        })
        contentView.addSubview(personalInfoLabel)
        personalInfoLabel.snp.makeConstraints({
            $0.centerY.equalTo(profileImage.snp.centerY)
            $0.left.equalTo(profileImage.snp.right).offset(16)
        })
        
        contentView.addSubview(lastMessageReceiveTimeLabel)
        lastMessageReceiveTimeLabel.snp.makeConstraints({
            $0.centerY.equalTo(personalInfoLabel.snp.centerY)
            $0.right.equalToSuperview().inset(16)
        })
        
        contentView.addSubview(newSparkLabel)
        newSparkLabel.snp.makeConstraints({
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(personalInfoLabel.snp.bottom).offset(8)
            $0.width.equalTo(100)
        })
        
        contentView.addSubview(LastMessageLabel)
        LastMessageLabel.snp.makeConstraints({
            $0.top.equalTo(personalInfoLabel.snp.bottom).offset(8)
            $0.left.equalTo(personalInfoLabel.snp.left)
            $0.right.equalTo(newSparkLabel.snp.left).offset(-8)
        })
    }
}
