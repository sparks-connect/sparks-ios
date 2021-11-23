//
//  NewMessageController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/24/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class NewMessageController : PageBaseController {
    
    //MARK: properties
    let presenter = NewMessagePresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private var maxCharCount : Int = FirebaseConfigManager.shared.maxCharacterCount

    private let headerView = MainHeaderView()
    
    private var textview : UITextView = {
        let view = UITextView()
        view.textColor = .white
        view.font = Font.regular.uiFont(ofSize: 16)
        view.tintColor = Color.purple.uiColor
        view.backgroundColor = Color.background.uiColor
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        return view
    }()
    
    private var placeholderLabel : Label = {
        let view = Label()
        view.textColor = Color.fadedLighter.uiColor
        view.font = Font.regular.uiFont(ofSize: 16)
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = "Think about meaningful message. Try to make it short and funny to attract the recipient."
        return view
    }()
    
    private var keyboardTopView : UIView = {
        let view = UIView()
        return view
    }()
    
    lazy private var characterCounter : UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.text = "0/\(maxCharCount)"
        return view
    }()
    
    private var sendButton : CircleLoadingButton = {
        let view = CircleLoadingButton()
        view.isEnabled = false
        view.setBackgroundColor(Color.purple.uiColor, forState: .normal)
        view.setBackgroundColor(.clear, forState: .disabled)
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(1, forState: .disabled)
        view.setBorderColor(.clear, forState: .normal)
        view.setBorderColor(.white, forState: .disabled)
        view.clipsToBounds = true
        view.setTitle("Send", for: .normal)
        return view
    }()

    override func configure() {
        super.configure()
        registerNotification()
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        textview.delegate = self
        layout()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textview.becomeFirstResponder()
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    private lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.05
        imageView.image = #imageLiteral(resourceName: "send_letter")
        return imageView
    }()
    
    private func layout(){
        
        view.addSubview(headerView)
        
        headerView.delegate = self
        headerView.title = "Wtite a nice message"
        headerView.image = Image.close.uiImage
        headerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(60)
        }
        
        view.addSubview(keyboardTopView)
        keyboardTopView.addSubview(characterCounter)
        keyboardTopView.addSubview(sendButton)
        view.addSubview(textview)
        
        keyboardTopView.snp.makeConstraints({
            $0.bottom.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(60)
        })
        
        sendButton.snp.makeConstraints({
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(40)
            $0.width.equalTo(110)
            $0.centerY.equalToSuperview()
        })
        
        characterCounter.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(24)
        }
        
        textview.snp.makeConstraints({
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(sendButton.snp.top).offset(-12)
        })
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalTo(textview)
            make.width.equalTo(textview.snp.width).multipliedBy(0.5)
            make.height.equalTo(imageView.snp.width)
        }
        
        view.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(textview.snp.left).offset(8)
            make.right.equalTo(textview.snp.right).offset(-8)
            make.top.equalTo(textview.snp.top).offset(4)
            make.height.equalTo(44)
        }
        
        keyboardTopView.layoutIfNeeded()
    }
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            keyboardTopView.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(60)
                make.bottom.equalToSuperview().offset(-(keyboardHeight + 8))
            }
        }
    }
    
    @objc private func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func sendMessage(){
        guard let text = textview.text, !text.isEmpty else { return }
        self.sendButton.startAnimatingLoader()
        
        main(block: {
            self.pageViewController?.switchTabToNext(parameters: ["text": text])
        }, after: 0.3)
    }
    
    override func notifyError(message: String, okAction: (() -> Void)? = nil) {
        super.notifyError(message: message)
        self.sendButton.stopAnimatingLoader()
    }
    
    override func reloadView() {
        super.reloadView()
        self.sendButton.stopAnimatingLoader()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NewMessageController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        characterCounter.text = "\(textView.text.count)/\(self.maxCharCount)"
        sendButton.isEnabled = textView.text.count > 0
        placeholderLabel.isHidden = textView.text.count > 0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= self.maxCharCount
    }
}

extension NewMessageController: NewMessageView {
    func didSentMessage() {
        self.dismissAction()
    }
}

extension NewMessageController: MainHeaderViewDelegate {
    @objc func didTapOnActionButton() {
        self.dismissAction()
    }
}
