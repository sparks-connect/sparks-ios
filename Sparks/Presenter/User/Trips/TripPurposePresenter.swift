//
//  TripPurposePresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol PurposeView: BasePresenterView {
    func navigate()
}

class TripPurposePresenter: BasePresenter<PurposeView> {
    func save(info: TripInfo?, purpose: PurposeEnum){
        info?.savePurpose(type: purpose)
        self.view?.navigate()
    }
}
