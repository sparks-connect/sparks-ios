//
//  GenderController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 6/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

protocol GenderView: BasePresenterView {
    func didUpdateGender()
}

class GenderPresenter: BasePresenter<GenderView> {

    var gender : Gender?
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.gender = User.current?.genderEnum
        self.view?.reloadView()
    }
    
    func updateGender() {
        guard let gender = gender else { return }
        auth.updateGender(gender) {[weak self] (result) in
            self?.handleResponse(response: result, preReloadHandler: {
                self?.view?.didUpdateGender()
            }, reload: false)
        }
     }
}
