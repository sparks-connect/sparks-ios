//
//  NameInputPresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

protocol NameInputView: BasePresenterView {
    func didUpdateName()
}

class NameInputPresenter: BasePresenter<NameInputView> {
    
    private let service = Service.auth
    
    func update(name: String) {
        
        if name.isEmpty {
            self.view?.notifyError(message: "Invalid name", okAction: nil)
            return
        }
        
        service.updateFirstname(name) {[weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.didUpdateName()
            }, reload: false)
        }
    }
}
