//
//  ChatNavBarView.swift
//  Sparks
//
//  Created by Nika Samadashvili on 3/30/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

protocol ChatNavBarViewDelegate : AnyObject {
    func didTapProfile()
    func didTapActionButton()
    func didTapBackButton()
}

class ChatNavBarView : BaseView {
    
    weak var delegate : ChatNavBarViewDelegate?
    private var imageLabel = ImageLabel()
    private var channel : Channel?
    
    private var actionButton : ChatActionButton = {
        let view = ChatActionButton(state: nil)
        view.updateButton(state: nil)
        return view
    }()
    
    private var backButton : UIButton = {
        let view = Button(type: .system)
        view.tintColor = .white
        return view
    }()
    
    var hasAction: Bool = false {
        didSet {
            actionButton.isHidden = !hasAction
        }
    }
    
    override init() {
        super.init()
        layout()
        imageLabel.setTextFont(.boldSystemFont(ofSize: 16))
        imageLabel.setTextColor(.white)
        backButton.setImage(#imageLiteral(resourceName: "backIcon"), for: .normal)
        actionButton.addTarget(self, action:#selector(didTapActionButton), for: .touchUpInside)
        backButton.addTarget(self, action:#selector(self.didTapBackButton), for: .touchUpInside)
        imageLabel.addTapGesture(target: self, selector: #selector(self.didTapProfileButton))
        backgroundColor = Color.background.uiColor
    }
    
    func stopAnimatingActionButton(){
        self.actionButton.stopAnimatingLoader()
    }
    
    func userIsEmpty() -> Bool {
        guard channel?.otherUsers.first != nil else { return true }
        return false
    }
    
    @objc private func didTapProfileButton(){
        self.delegate?.didTapProfile()
    }
    
    @objc private func didTapActionButton(){
        self.delegate?.didTapActionButton()
    }
    
    @objc private func didTapBackButton(){
        self.delegate?.didTapBackButton()
    }
    
    func set(state: CurrentUserShareState?) {
        imageLabel.set(channel, user: nil)
        imageLabel.setText(channel?.otherUsers.first?.displayName ?? "")
        self.actionButton.updateButton(state: state)
    }
    
    private func layout() {
        
        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview().inset(-10)
            $0.width.equalTo(70)
            $0.height.equalTo(70)
        }
        
        addSubview(imageLabel)
        imageLabel.snp.makeConstraints({
            $0.left.equalTo(backButton.snp.right).inset(25)
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.width.equalTo(100)
            $0.height.equalTo(35)
        })
        
        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(10)
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.width.equalTo(70)
            $0.height.equalTo(25)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatNavBarView {
    func setupChannel(channel: Channel?){
        guard let channel = channel else { return }
        self.channel = channel
    }
    
}
