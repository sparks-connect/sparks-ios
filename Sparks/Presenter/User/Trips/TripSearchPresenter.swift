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
    
    func getLocation(info: PlaceInfo) {
        self.placeInfo = info
        self.view?.updateLocation(text: info.place)
    }
    
    func saveCriteria(){
        
        var criteria = TripCriteria.get
        if (criteria == nil) {
            criteria = TripCriteria(city: self.placeInfo?.place ?? "",
                         startDate: 0,
                         endDate: 2524593600000000,
                         gender: Gender.both)
            TripCriteria.create(criteria: criteria!)
        } else {
            criteria?.save(city: self.placeInfo?.place ?? "", startDate: 0, endDate: 2524593600000000, gender: Gender.both)
        }
    }
    
    override func willDisappear() {
        super.willDisappear()
        self.saveCriteria()
    }
}
