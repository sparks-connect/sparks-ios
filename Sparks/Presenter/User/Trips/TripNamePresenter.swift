//
//  TripNamePresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 09/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol TripNameView: BasePresenterView {
    func updateLocation(text: String?)
}

class TripNamePresenter: BasePresenter<TripNameView>, Place {
    var placeInfo: PlaceInfo?
    func getLocation(info: PlaceInfo) {
        self.placeInfo = info
        self.view?.updateLocation(text: info.place)
    }
}
