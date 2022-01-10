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
import AuthenticationServices
import Firebase

class SocialSigninController: PageBaseController {
    private let presenter = SocialInputPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
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
    
    override func didAppear() {
        super.didAppear()
        performExistingAccountSetupFlows()
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
                self.setNavigation()
                break
            }
        }
    }
    
    @objc private func loginAppleAction(sender: AnyObject) {
        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

    }
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]

        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc private func loginGoogleAction(sender: AnyObject) {
        
        Service.auth.googleAuth(controller: self) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
                break
            case .success(_):
                self.setNavigation()
                break
            }
        }
    }
    
    private func setNavigation() {
        if User.current?.isMissingRequredInfo == true {
            AppDelegate.makeRootViewController(OnboardingPageViewController())
        }else {
            AppDelegate.updateRootViewController()
        }
    }
}

extension SocialSigninController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
                    
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user

            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            Service.auth.appleAuth(credential: credential) { (result) in
                switch result {
                case .failure(let error):
                    debugPrint(error)
                    break
                case .success(_):
                    self.setNavigation()
                    break
                }
            }
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: Bundle.main.description, account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension SocialSigninController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
