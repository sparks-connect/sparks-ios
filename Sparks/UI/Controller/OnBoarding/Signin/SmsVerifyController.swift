//
//  SmsVerifyController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class SmsVerifyController: PageBaseController {
    
    private var presenter = SmsVerifyPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private lazy var titleLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.bold.uiFont(ofSize: 32)
        view.textColor = .white
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        view.numberOfLines = 0
        view.text = "Verify your phone number"
        return view
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.regular.uiFont(ofSize: 15)
        view.textColor = .lightGray
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        view.text = "We won't share your phone number to anybody"
        return view
    }()
    
    private lazy var haventReceivedLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.regular.uiFont(ofSize: 15)
        view.textColor = .lightGray
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        view.text = "Haven't received code ?"
        return view
    }()
    
    private lazy var resendButton : UIButton = {
        let view = UIButton()
        view.titleLabel?.font =  Font.regular.uiFont(ofSize: 15)
        view.setTitleColor(Color.purple.uiColor, for: .normal)
        view.setTitleColor(Color.gray.uiColor, for: .disabled)
        view.isEnabled = false
        view.setTitle("RESEND CODE", for: .normal)
        view.addTarget(self, action: #selector(resendClicked), for: .touchUpInside)
        return view
    }()
    
    private lazy var resendDesc: UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.regular.uiFont(ofSize: 10)
        view.textColor = .lightGray
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        return view
    }()
    
    private lazy var otpInput: OtpInput = {
        let view = OtpInput()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .medium
        view.color = .white
        return view
    }()
    
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Onboarding"
        self.layout()
    }

    override func didAppear() {
        super.didAppear()
        main(block: {
        _ = self.otpInput.becomeFirstResponder()
        }, after: 0.5)
    }
    
    override func willDisappear() {
        super.willDisappear()
        _ = self.otpInput.resignFirstResponder()
    }
    
    private func layout() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(otpInput)
        self.view.addSubview(haventReceivedLabel)
        self.view.addSubview(resendButton)
        self.view.addSubview(resendDesc)
        self.view.addSubview(loader)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(100)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(titleLabel.snp.right)
            make.top.equalTo(titleLabel.snp.bottom).inset(8)
            make.height.equalTo(30)
        }
        
        otpInput.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.height.equalTo(80)
        }
        
        haventReceivedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(otpInput.snp.bottom).offset(16)
            make.left.right.equalTo(otpInput)
            make.height.equalTo(20)
        }
        
        resendButton.snp.makeConstraints { (make) in
            make.top.equalTo(haventReceivedLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(28)
        }
        
        resendDesc.snp.makeConstraints { (make) in
            make.top.equalTo(resendButton.snp.bottom).offset(4)
            make.left.right.equalTo(otpInput)
            make.height.equalTo(16)
        }
        
        loader.snp.makeConstraints { (make) in
            make.left.equalTo(resendButton.snp.right).offset(8)
            make.centerY.equalTo(resendButton)
        }
    }
    
    override func didUpdateParameters() {
        
        let phone = self.parameters?["phone"] as? String ?? ""
        let id = self.parameters?["verificationID"] as? String ?? ""
        
        self.presenter.phone = phone
        self.presenter.verificationID = id
        
        self.descriptionLabel.text = "Code was sent to: \(self.presenter.phone)"
    }
    
    override func notifyError(message: String, okAction: (() -> Void)? = nil) {
        self.loader.stopAnimating()
        super.notifyError(message: message) {
            _ = self.otpInput.becomeFirstResponder()
        }
    }
    
    @objc private func resendClicked() {
        self.loader.startAnimating()
        self.resendButton.isEnabled = false
        self.presenter.resend()
    }
    
    override func reloadView() {
        super.reloadView()
        self.loader.stopAnimating()
        self.resendButton.isEnabled = self.presenter.resendIsAvailable
        if self.presenter.resendIsAvailable {
            self.resendDesc.text = "Try again now"
        } else {
            self.resendDesc.text = "You can resend code after \(Int(self.presenter.elapsed)) seconds"
        }
    }
}

extension SmsVerifyController: OtpInputDelegate {
    func otpInput(didFill otp: String) {
        _ = self.otpInput.resignFirstResponder()
        self.presenter.signIn(code: otp)
    }
}

extension SmsVerifyController: SmsVerifyView {
    func didLoginSuccessfully() {
        AppDelegate.updateRootViewController()
    }
}
