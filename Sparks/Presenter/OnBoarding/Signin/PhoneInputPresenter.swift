//
//  PhoneInputPresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/17/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

protocol PhoneInputView: BasePresenterView {
    func didVerifyPhoneNumber(verificationID: String)
    func validate()
}

class PhoneInputPresenter: BasePresenter<PhoneInputView> {
    
    private let service = Service.auth
    var phoneNumber: String? {
        didSet {
            self.view?.validate()
        }
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.view?.validate()
 
    }
    
    func verify() {
        guard let phone = self.phoneNumber else { return }
        self.service.verifyPhoneNumber(phone) {[weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                let verificationID = try? response.get()
                self?.view?.didVerifyPhoneNumber(verificationID: verificationID ?? "")
            }, reload: false)
        }
    }
    
    func phoneIsValid() -> Bool {
        guard let phone = self.phoneNumber else { return false }
        return phone.count > 9
    }
}
