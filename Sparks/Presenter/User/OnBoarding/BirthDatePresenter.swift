//
//  BirthDatePresenter.swift
//  Sparks
//
//  Created by Nika Samadashvili on 6/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

protocol BirthDateView: BasePresenterView {
    func didUpdateBirthdate()
}

class BirthDatePresenter: BasePresenter<BirthDateView> {

    var birthDate : Int64?
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.birthDate = User.current?.birthDate
        self.view?.reloadView()
    }
    
    func updateBirthDate() {
        guard let birthDate = birthDate else { return }
        auth.updateBirthDate(birthDate) {[weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.didUpdateBirthdate()
            }, reload: false)
        }
    }
}
