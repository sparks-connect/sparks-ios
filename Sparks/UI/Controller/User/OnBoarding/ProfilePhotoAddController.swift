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
    
    private lazy var cropper: ImageCropperUtil = {
        let cropper = ImageCropperUtil(viewController: self)
        cropper.delegate = self
        return cropper
    }()
    
    private lazy var titleLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.bold.uiFont(ofSize: 32)
        view.textColor = .white
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        view.numberOfLines = 0
        view.text = "Add Profile Photo"
        return view
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let view = Label()
        view.textAlignment = .center
        view.font =  Font.regular.uiFont(ofSize: 15)
        view.textColor = .lightGray
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.5
        view.text = "Your photo won't be shared unless you both unlock"
        return view
    }()
    
    private lazy var nextButton: PrimaryButton = {
        let view = PrimaryButton()
        view.setTitle("Next", for: .normal)
        view.isEnabled = false
        view.addTarget(self, action: #selector(nextClicked), for: .touchUpInside)
        return view
    }()
    
    private lazy var addButton: ProfilePhotoAddButton = {
        let view = ProfilePhotoAddButton()
        view.imageURL = User.current?.photoUrl
        view.addTarget(self, action: #selector(addPhotoClicked), for: .touchUpInside)
        view.addTarget(self, action: #selector(addPhotoValueChanged), for: .valueChanged)
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
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(addButton)
        self.view.addSubview(nextButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(100)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(titleLabel.snp.right)
            make.top.equalTo(titleLabel.snp.bottom).inset(8)
            make.height.equalTo(30)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(addButton.snp.width)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-32)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(64)
        }
    }
    
    @objc private func nextClicked() {
        self.presenter.showInstaAuthorization()
    }
    
    @objc private func addPhotoClicked() {
        self.cropper.showImagePicker(otherActions: [], title: "Crop photo")
    }
    
    @objc private func addPhotoValueChanged() {
        self.nextButton.isEnabled = self.addButton.imageIsSet
    }
    
    override func reloadView() {
        super.reloadView()
        self.nextButton.stopAnimatingLoader()
        self.addButton.imageURL = User.current?.photoUrl
    }
    
    func setAccessToken(_ code: String) {
        self.presenter.getInstaAccessToken(code: code)
    }
    
}

extension ProfilePhotoAddController: ImageCropperUtilDelegate {
    
    func didCropImage(image: UIImage) {
        self.nextButton.isEnabled = false
        self.nextButton.startAnimatingLoader()
        self.presenter.uploadImage(image: image)
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

