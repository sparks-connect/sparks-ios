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
import Photos
import MapKit

class ProfilePhotoAddController: BaseController {
    
    private let presenter = ProfilePhotoAddPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    var isMainPhoto: Bool = false
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.addTarget(self, action: #selector(skipClicked), for: .touchUpInside)
        return btn
    }()
    
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
        let title = User.current?.isMissingInstaToken ?? false ? "Connect Instagram" : "Instagram"
        view.setTitle(title, for: .normal)
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
        self.view.addSubview(backBtn)
        self.view.addSubview(titleLabel)
        self.view.addSubview(stackView)
        self.view.addSubview(skipButton)
        
        backBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(64)
        }
        
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
        self.presenter.isProfilePic = self.isMainPhoto
        guard let user = User.current else { return }
        if user.isMissingInstaToken {
            self.presenter.showInstaAuthorization()
        }else {
            self.presenter.getMedia()
        }
    }
    
    @objc private func galleryClicked(){
        self.fetchGallaryData()
    }
    
    @objc private func skipClicked() {
        self.dismiss(animated: true, completion: nil)
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
        let controller = WebViewController(url: url)
        controller.request = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func navigate(assets: [PhotoAsset]) {
        let controller = AssetSelectViewController()
        controller.photoAssets = assets
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        controller.maxSelectionCount = self.isMainPhoto ? 1 : 10
        self.present(controller, animated: true, completion: nil)
    }
    
    func fetchGallaryData(){
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .denied || status == .restricted) {
            return
        }else{
            PHPhotoLibrary.requestAuthorization { (authStatus) in
                if authStatus == .authorized{
                    let imageAsset = PHAsset.fetchAssets(with: .image, options: nil)
                    if imageAsset.count>0{
                        main {
                            let controller = AssetSelectViewController()
                            controller.assets = imageAsset
                            controller.delegate = self
                            controller.maxSelectionCount = self.isMainPhoto ? 1 : 10
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }
    }
    
}

extension ProfilePhotoAddController: Request {
    func validateRequest(request: URLRequest,controller: UIViewController) {
        if let code = self.getTokenFromCallbackURL(request: request) {
            controller.dismiss(animated: true) {
                self.setAccessToken(code)
            }
        }
    }
    
    private func getTokenFromCallbackURL(request: URLRequest) -> String? {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.starts(with: "\(Consts.Insta.redirectURI)?code=") {
            
            print("Response uri:",requestURLString)
            if let range = requestURLString.range(of: "\(Consts.Insta.redirectURI)?code=") {
                return String(requestURLString[range.upperBound...].dropLast(2))
            }
        }
        return nil
    }
}

extension ProfilePhotoAddController: AssetSelectViewControllerDelegate {
    func assetsSelected(assets: [PhotoAsset]) {
        self.presenter.sendPhotos(photos: assets)
        self.dismiss(animated: true, completion: nil)
    }
}

protocol Request: AnyObject {
    func validateRequest(request: URLRequest,controller: UIViewController)
}

class WebViewController: BaseController {
    
    private lazy var titeLabel: Label = {
        let lbl = Label()
        lbl.textAlignment = .center
        lbl.font =  UIFont.systemFont(ofSize: 18, weight:.bold)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.text = Bundle.main.displayName ?? ""
        return lbl
    }()
    
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "close"), for: .normal)
        btn.addTarget(self, action: #selector(back), for: .touchUpInside)
        return btn
    }()
    
    private lazy var webView: WKWebView = {
        let web = WKWebView()
        web.translatesAutoresizingMaskIntoConstraints = false
        web.navigationDelegate = self
        web.backgroundColor = .clear
        return web
    }()
    private var requestURL: URL!
    weak var request: Request?
    
    init(url: URL){
        self.requestURL = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        super.configure()
        
        self.view.addSubview(titeLabel)
        titeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }
        
        self.view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titeLabel)
        }
        
        self.view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(44)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        webView.load(URLRequest(url: requestURL))
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.request?.validateRequest(request: navigationAction.request,controller: self)
        decisionHandler(WKNavigationActionPolicy.allow)
    }
}

extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
