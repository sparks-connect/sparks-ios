//
//  PhoneInputController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/17/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class PhoneInputController: PageBaseController {
    
    private let presenter = PhoneInputPresenter()
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
        view.text = "Input your phone number"
        return view
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.regular.uiFont(ofSize: 15)
        view.textColor = .lightGray
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 0
        view.text = "We only use your phone number to verify your identity, we don't store it for any purposes"
        return view
    }()
    
    private lazy var phoneInput: PhoneInput = {
        let view = PhoneInput()
        view.addTarget(self, action: #selector(phoneChanged), for: .valueChanged)
        view.addTarget(self, action: #selector(prefixSelected), for: .touchUpInside)
        return view
    }()
    
    private lazy var verifyButton: PrimaryButton = {
        let view = PrimaryButton()
        view.setTitle("Verify", for: .normal)
        view.addTarget(self, action: #selector(verify), for: .touchUpInside)
        return view
    }()
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Sparks"
        self.registerNotification()
        self.layout()
    }

    override func didAppear() {
        super.didAppear()
        main(block: {
            _ = self.phoneInput.becomeFirstResponder()
        }, after: 0.5)
        
    }
    
    private func layout() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(phoneInput)
        self.view.addSubview(verifyButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerY.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(100)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).inset(8)
        }
        
        phoneInput.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.height.equalTo(60)
        }
        
        verifyButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-32)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(64)
        }
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification, show: Bool) {
        showKeyboard(notification, show: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification, show: Bool) {
        showKeyboard(notification, show: false)
    }
    
    private func showKeyboard(_ notification: Notification, show: Bool) {
        
        guard let userInfo = notification.userInfo else { return }
        
        var animationSpeed = 0.3
        
        let curve = UInt(truncating: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber) << 16
        let options = UIView.AnimationOptions(rawValue: curve)
        
        if let speed = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSValue) {
            var duration : TimeInterval = 0
            speed.getValue(&duration)
            animationSpeed = duration
        }
        
        if let keyboardFrame: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            verifyButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(show ? -(16 + keyboardRectangle.height) : -32)
                make.left.equalTo(32)
                make.right.equalTo(-32)
                make.height.equalTo(64)
            }
        }
        
        UIView.animate(withDuration: animationSpeed,
                       delay: 0,
                       options: options,
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func phoneChanged() {
        self.presenter.phoneNumber = self.phoneInput.phone
    }
    
    @objc private func prefixSelected() {
        let controller = CountryChooserViewController()
        controller.modalPresentationStyle = .overFullScreen
        controller.delegate = self
        self.present(controller, animated: false, completion: nil)
    }
    
    @objc private func verify() {
        self.verifyButton.startAnimatingLoader()
        self.presenter.verify()
    }
    
    override func reloadView() {
        super.reloadView()
        self.verifyButton.startAnimatingLoader()
    }
    
    override func notifyError(message: String, okAction: (() -> Void)? = nil) {
        super.notifyError(message: message)
        self.verifyButton.startAnimatingLoader()
    }
}

extension PhoneInputController: PhoneInputView {
    
    func didVerifyPhoneNumber(verificationID: String) {
        _ = self.phoneInput.resignFirstResponder()
        
        main(block: {
            self.verifyButton.stopAnimatingLoader()
            self.pageViewController?.switchTabToNext(parameters: [
                "phone": self.presenter.phoneNumber ?? "",
                "verificationID": verificationID
            ])
        }, after: 0.25)
    }
    
    func validate() {
        self.verifyButton.isEnabled = self.presenter.phoneIsValid()
    }
}

extension PhoneInputController: CountryChooserViewDelegate {
    func onCountrySelected(_ country: Country) {
        self.phoneInput.prefixView.country = country
        self.phoneChanged()
    }
}
