//
//  SocialSigninController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 22/12/21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class SocialSigninController: PageBaseController {
    private let presenter = SocialInputPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private lazy var getStartedLabel : UILabel = {
        let view = Label()
        view.font =  Font.bold.uiFont(ofSize: 32)
        view.textColor = .white
        view.text = "Get Started"
        return view
    }()
    
    private lazy var welcomeImg: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "walkthrough")
        return imgView
    }()
    
    private var termsLabel: FlexibleTextView = {
        let label = FlexibleTextView()
        label.texts = [
            ("By joining you accept our ", nil),
            ("Terms and Conditions", URL(string: "https://Sparks.ge")),
            (" and ", nil),
            ("Privacy Policy", URL(string: "https://Sparks.ge"))
        ]
        label.maxFontSize = 15
        label.textPartColor = Color.lightPurple.uiColor
        label.urlPartColor = Color.fadedPurple.uiColor
        label.backgroundColor = .clear
        label.alignment = .center
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [facebookButton, appleButton, googleButton])
        stack.spacing = 18
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    
    private lazy var facebookButton : ArrowButton = {
        let view = ArrowButton(image: Image.facebook.uiImage, labelText: "Continue with facebook")
        view.borderWidth = 0
        view.addTarget(self, action: #selector(loginFacebookAction), for: .touchUpInside)
        view.setTitleColor(Color.fb.uiColor)
        view.backgroundColor = Color.lightGray2.uiColor
        view.setFont(Font.bold.uiFont(ofSize: 14))
        return view
    }()
    
    private var appleButton : ArrowButton = {
        let view = ArrowButton(image: Image.apple.uiImage, labelText: "Continue with apple")
        view.addTarget(self, action: #selector(loginAppleAction), for: .touchUpInside)
        view.setTitleColor(Color.background.uiColor)
        view.borderWidth = 0
        view.backgroundColor = Color.lightGray2.uiColor
        view.setFont(Font.bold.uiFont(ofSize: 14))
        return view
    }()
    
    private var googleButton : ArrowButton = {
        let view = ArrowButton(image: Image.google.uiImage, labelText: "Continue with Google")
        view.addTarget(self, action: #selector(loginGoogleAction), for: .touchUpInside)
        view.setTitleColor(Color.google.uiColor)
        view.borderWidth = 0
        view.backgroundColor = Color.lightGray2.uiColor
        view.setFont(Font.bold.uiFont(ofSize: 14))
        return view
    }()
    
    override func configure() {
        super.configure()
        self.layout()
    }
    
    private func layout(){
        view.addSubview(welcomeImg)
        welcomeImg.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(48)
        }
        
        view.addSubview(getStartedLabel)
        getStartedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(getStartedLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
                
        view.addSubview(termsLabel)
        termsLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(64)
        }

    }
    
    @objc private func loginFacebookAction(sender: AnyObject) {
        
        Service.auth.fbAuth(controller: self) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
                break
            case .success(_):
                AppDelegate.updateRootViewController()
                break
            }
        }
    }
    
    @objc private func loginAppleAction(sender: AnyObject) {
        
        Service.auth.appleAuth(controller: self) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
                break
            case .success(_):
                AppDelegate.updateRootViewController()
                break
            }
        }
    }
    
    @objc private func loginGoogleAction(sender: AnyObject) {
        
        Service.auth.googleAuth(controller: self) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
                break
            case .success(_):
                AppDelegate.updateRootViewController()
                break
            }
        }
    }
}
