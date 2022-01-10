//
//  SocialInputPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 22/12/21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol SocialInputView: BasePresenterView {
    func navigate()
}

class SocialInputPresenter: BasePresenter<SocialInputView> {
    private let service = Service.auth
    
    enum LoginType {
        case facebook
        case google
        case apple(credential: AuthCredential)
    }
    
    func login(type: LoginType, controller: UIViewController) {
        switch type {
        case .facebook:
            self.facebookLogin(vc: controller)
        case .google:
            self.googleLogin(vc: controller)
        case .apple(let credential):
            self.appleLogin(credential: credential)
        }
    }
    
    private func facebookLogin(vc: UIViewController){
        self.service.fbAuth(controller: vc) { [weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.navigate()
            }, reload: false)
        }
    }
    
    private func googleLogin(vc: UIViewController) {
        self.service.googleAuth(controller: vc) { [weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.navigate()
            }, reload: false)
        }
    }
    
    private func appleLogin(credential: AuthCredential) {
        self.service.appleAuth(credential: credential) { [weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.navigate()
            }, reload: false)
        }
    }
}
