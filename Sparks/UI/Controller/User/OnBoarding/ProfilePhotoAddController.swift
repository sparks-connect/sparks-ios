//
//  ProfilePhotoAddController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SafariServices
import WebKit


class ProfilePhotoAddController: PageBaseController {
    
    private let presenter = ProfilePhotoAddPresenter()
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
        view.text = "Add Photos"
        return view
    }()
    
    private lazy var stackView : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var instaButton: UIButton = {
        let view = UIButton()
        view.setTitle("Connect Instagram", for: .normal)
        view.setBackgroundImage(UIImage(named: "insta"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.font(for: 14, style: .bold)
        view.addTarget(self, action: #selector(instaClicked), for: .touchUpInside)
        return view
    }()
    
    private lazy var galleryButton: UIButton = {
        let view = UIButton()
        view.setTitle("Add photos from gallery", for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.font(for: 14, style: .bold)
        view.addTarget(self, action: #selector(galleryClicked), for: .touchUpInside)
        return view
    }()
    
    private lazy var skipButton: UIButton = {
        let view = UIButton()
        view.setTitle("Remind me later", for: .normal)
        view.setTitleColor(Consts.Colors.skipText, for: .normal)
        view.titleLabel?.font = UIFont.font(for: 14, style: .regular)
        view.addTarget(self, action: #selector(skipClicked), for: .touchUpInside)
        return view
    }()
    
    override func configure() {
        super.configure()
        self.layout()
    }
    
    override func willAppear() {
        super.willAppear()
    }
    
    private func layout() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(stackView)
        self.view.addSubview(skipButton)
        
        stackView.addArrangedSubview(instaButton)
        stackView.addArrangedSubview(galleryButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(100)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.equalTo(24)
            make.trailing.equalTo(-24)
            make.height.equalTo(120)
        }
        
        skipButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-32)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(64)
        }
    }
    
    @objc private func instaClicked() {
        self.presenter.showInstaAuthorization()
    }
    
    @objc private func galleryClicked() {
//        self.presenter.showInstaAuthorization()
    }
    
    @objc private func skipClicked() {
//        self.presenter.showInstaAuthorization()
    }
    
    @objc private func nextClicked() {
//        self.presenter.showInstaAuthorization()
    }
    
    override func reloadView() {
        super.reloadView()
    }
    
    func setAccessToken(_ code: String) {
        self.presenter.getInstaAccessToken(code: code)
    }
    
}

extension ProfilePhotoAddController: ProfilePhotoAddView {    
    func showAuthorizationWindow(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
}

extension ProfilePhotoAddController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo url: URL) {
        if url.lastPathComponent != "authorize" {
            if let callback = url.getQueryParameterValue(param: "u"),
               let redirectURL = URL(string: callback),
               let code = redirectURL.getQueryParameterValue(param: "code"){
                self.setAccessToken(code)
                controller.dismiss(animated: true, completion: nil)
            }
        }
    }
}

