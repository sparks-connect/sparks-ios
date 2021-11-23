//
//  NewMessageController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/24/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class MessageSentController: PageBaseController {
    
    //MARK: properties
    let presenter = NewMessagePresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }

    private struct Consts {
        static let doneButtonTitle: String = "Done"
        static let controlleTitle: String =  "Compose Message"
        static let messageSentTitle: String = "Message sent to random person"
        static let messageSentDesc: String = "Spin and get more than swipes"
    }
    
    private let headerView: MainHeaderView = {
        let view = MainHeaderView()
        view.title = Consts.doneButtonTitle
        view.image = Image.close.uiImage
        return view
    }()
    
    private let doneButton : LoadingButton = {
        let view = LoadingButton()
        view.setBackgroundColor(Color.lightBackground.uiColor, forState: .normal)
        view.clipsToBounds = true
        view.setTitle(Consts.doneButtonTitle, for: .normal)
        view.setBorderWidth(0, forState: .normal)
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let imageView: ImageView = {
        let view = ImageView()
        view.image = Image.sendBallons.uiImage
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let titleLabel: Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 32)
        view.textColor = .white
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = Consts.messageSentTitle
        return view
    }()
    
    private let descriptionLabel: Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = Color.fadedPurple.uiColor
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = Consts.messageSentDesc
        return view
    }()

    override func configure() {
        super.configure()
        doneButton.addTarget(self, action: #selector(didPressDoneBtn), for: .touchUpInside)
        headerView.delegate = self
        layout()
    }

    private func layout(){
        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(60)
        }
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints({
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(60)
            $0.bottom.equalTo(self.view.safeAreaInsets.bottom).inset(24)
        })
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(30)
            $0.height.equalToSuperview().multipliedBy(0.4)
            $0.right.left.equalToSuperview().inset(80)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(55)
            $0.top.equalTo(imageView.snp.bottom).inset(30)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).inset(-20)
            $0.left.right.equalToSuperview().inset(55)
        }
    }
    

    @objc private func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func didPressDoneBtn(){
        dismissAction()
    }

}


extension MessageSentController: MainHeaderViewDelegate {
    @objc func didTapOnActionButton() {
        self.dismissAction()
    }
}
