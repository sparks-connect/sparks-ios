//
//  TripSearchPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol TripSearchView: BasePresenterView {
    func updateLocation(text: String?)
}

class TripSearchPresenter: BasePresenter<TripSearchView>, Place {
    var placeInfo: PlaceInfo?
    var startDate: Int64?
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.saveCriteria()
    }

    func getLocation(info: PlaceInfo) {
        self.placeInfo = info
        self.view?.updateLocation(text: info.place)
    }
    
    func saveCriteria(){
        let criteria = TripCriteria(city: self.placeInfo?.place ?? "",
                                    startDate: Date().milliseconds,
                                    endDate: Date().milliseconds,
                                    gender: Gender.female)
        criteria.update(criteria: criteria)
    }
}
