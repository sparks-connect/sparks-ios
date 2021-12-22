//
//  SocialInputPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 22/12/21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

protocol SocialInputView: BasePresenterView {
    func validate()
}

class SocialInputPresenter: BasePresenter<SocialInputView> {
    private let service = Service.auth

}
