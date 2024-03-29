//
//  NameInputController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class NameInputController: PageBaseController {
    private let presenter = NameInputPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private lazy var inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.fadedBackground.uiColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showEditor)))
        view.addSubview(input)
        input.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var input: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 20)
        view.textColor = .white
        return view
    }()
    
    private lazy var titleLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.bold.uiFont(ofSize: 32)
        view.textColor = .white
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        view.numberOfLines = 0
        view.text = "Enter your name"
        return view
    }()
    
    private lazy var updateButton: PrimaryButton = {
        let view = PrimaryButton()
        view.setTitle("Next", for: .normal)
        view.isEnabled = false
        view.addTarget(self, action: #selector(update), for: .touchUpInside)
        return view
    }()
    
    override func configure() {
        super.configure()
        self.registerNotification()
        self.layout()
    }
    
    override func willAppear() {
        super.willAppear()
        
    }
    
    
    private func loadFullnameEditMode(type: EditKey, value: String) {
        let controller = OnKbdEditorViewController
            .createModule(text: value,
                          viewTitle: titleLabel.text ?? "",
                          inputTitle: type.rawValue,
                          placeholder: type.rawValue,
                          customKey: type.rawValue,
                          delegate: self)
        controller.inputKind = type.inputKind
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    private func layout() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(inputContainer)
        self.view.addSubview(updateButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(100)
        }
        
        inputContainer.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(60)
        }
        
        updateButton.snp.makeConstraints { (make) in
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
            updateButton.snp.makeConstraints { (make) in
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
    
    @objc private func showEditor() {
        self.loadFullnameEditMode(type: .name, value: self.input.text ?? "")
    }
    
    @objc private func update() {
        self.updateButton.startAnimatingLoader()
        self.presenter.update(name: self.input.text ?? "")
    }
    
    override func notifyError(message: String, okAction: (() -> Void)? = nil) {
        super.notifyError(message: message, okAction: okAction)
        self.updateButton.stopAnimatingLoader()
    }
    
}

extension NameInputController: OnKbdEditorViewControllerDelegate {
    func onDone(with text: String?, pickerValue: String?, dateValue: __int64_t, customKey: String?) {
        self.input.text = text
        self.updateButton.isEnabled = !self.input.text.isEmpty
    }
}

extension NameInputController: NameInputView {
    func didUpdateName() {
        self.updateButton.stopAnimatingLoader()
        if User.current?.isMissingRequredInfo == true {
            self.pageViewController?.switchTabToNext(parameters: nil)
        } else {
            AppDelegate.updateRootViewController()
        }
    }
}
