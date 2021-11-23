//
//  ProfileTagsController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 22.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

class ProfileTagsController: PageBaseController {
    
    let presenter = ProfileTagsPresenter()
    override func getPresenter() -> Presenter {
        return presenter
    }
    
    private var once = false
    
    private(set) lazy var tagsView: TagCollectionView = {
        let tagsView = TagCollectionView()
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.didSelectItem = {[weak self](indexPath) in
            self?.presenter.update(indexPath: indexPath)
        }
        return tagsView
    }()
    
    private(set) lazy var lblTitle: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.textAlignment = .center
        view.font = UIFont.font(for: 26, style: .bold)
        view.text = "Choose your interests"
        return view
    }()
    
    private(set) lazy var lblDesc: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = Color.lightGray.uiColor
        view.numberOfLines = 0
        view.minimumScaleFactor = 0.7
        view.lineBreakMode = .byTruncatingTail
        view.textAlignment = .center
        view.font = UIFont.font(for: 14, style: .regular)
        view.text = "Select up to 10 interests. This will help you to find best matches."
        return view
    }()
    
    private lazy var tagFilterInput: TextField = {
        let view = TextField()
        view.alpha = 0
        view.delegate = self
        view.backgroundColor = Color.fadedBackground.uiColor
        view.font = UIFont.font(for: 15, style: .regular)
        view.attributedPlaceholder = NSAttributedString(string: "Search for interests (e.g. music, snowboarding ... etc)",
                                                        attributes: [
                                                                        NSAttributedString.Key.foregroundColor: Color.lightGray.uiColor,
                                                                        NSAttributedString.Key.font: UIFont.font(for: 15, style: .regular),
                                                                    ])
        view.textColor = .white
        view.addTarget(self, action: #selector(tagFilterChanged), for: .editingChanged)
        return view
    }()
    
    private lazy var btnDone: PrimaryButton = {
        let view = PrimaryButton()
        view.setTitle("Done", for: .normal)
        view.isEnabled = false
        view.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
        return view
    }()
    
    private lazy var btnMore: UIButton = {
        let view = UIButton()
        view.setTitle("More...", for: .normal)
        view.titleLabel?.font = UIFont.font(for: 15, style: .regular)
        view.addTarget(self, action: #selector(moreClicked), for: .touchUpInside)
        view.setTitleColor(Color.lightGray.uiColor, for: .normal)
        return view
    }()
    
    override func configure() {
        super.configure()
        self.tagsView.backgroundColor = Color.background.uiColor
        self.view.backgroundColor = Color.background.uiColor
        
        self.view.addSubview(lblTitle)
        self.view.addSubview(lblDesc)
        self.view.addSubview(tagsView)
        self.view.addSubview(btnDone)
        self.view.addSubview(tagFilterInput)
        self.view.addSubview(btnMore)
        
        self.layout()
        self.registerNotification()
    }
    
    private func layout() {
        
        lblTitle.snp.makeConstraints { make in
            make.top.equalTo(64)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(90)
        }
        
        lblDesc.snp.makeConstraints { make in
            make.top.equalTo(lblTitle.snp.bottom).offset(16)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(48)
        }
        
        btnDone.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.left.equalTo(32)
            $0.right.equalTo(-32)
            $0.height.equalTo(64)
        }
        
        tagsView.snp.makeConstraints { make in
            make.top.equalTo(lblDesc.snp.bottom).offset(32)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        btnMore.snp.makeConstraints { make in
            make.top.equalTo(tagsView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        tagFilterInput.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnMore.snp.remakeConstraints { make in
            
            let y = -(tagsView.bounds.size.height - tagsView.collectionView.contentSize.height)
            make.top.equalTo(tagsView.snp.bottom).offset(y < 0 ? y : 8)
            make.centerX.equalToSuperview()
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
            tagFilterInput.snp.remakeConstraints { (make) in
                if show {
                    make.bottom.equalTo(-keyboardRectangle.height)
                } else {
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                }
                
                make.left.right.equalToSuperview()
                make.height.equalTo(64)
            }
        }
        
        tagFilterInput.alpha = show ? 1 : 0
        btnMore.alpha = show ? 0 : 1
        
        UIView.animate(withDuration: animationSpeed,
                       delay: 0,
                       options: options,
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func doneClicked(sender: AnyObject) {
        if let vc = self.pageViewController {
            vc.switchTabToNext(parameters: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func moreClicked(sender: AnyObject) {
        self.tagFilterInput.becomeFirstResponder()
    }
    
    @objc private func tagFilterChanged(sender: UITextField) {
        self.presenter.filter(text: sender.text)
    }
    
    override func reloadView() {
        super.reloadView()
        self.btnDone.isEnabled = User.current?.profileTags.isEmpty == false
        self.tagsView.contentTags = self.presenter.dataSource
        self.tagsView.currentSelections = User.current?.profileTags.map({ $0 }) ?? []
    }
}

extension ProfileTagsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = ""
        self.presenter.filter(text: "")
        self.view.endEditing(true)
        return false
    }
}

extension ProfileTagsController: ProfileTagsView {
    func refreshTags() {
        
    }
}
