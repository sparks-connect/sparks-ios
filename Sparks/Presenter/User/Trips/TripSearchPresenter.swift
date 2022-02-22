//
//  TripSearchPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import CoreLocation

protocol TripSearchView: BasePresenterView {
    func updateLocation(text: String?)
    func updateView(age: Age?, gender: Gender?, startDate: Int64?, endDate: Int64?)
}

class TripSearchPresenter: BasePresenter<TripSearchView>, Place {
    var placeInfo: PlaceInfo?
    var criteria = TripCriteria.get
    
    func getLocation(info: PlaceInfo) {
        self.placeInfo = info
        self.view?.updateLocation(text: info.place)
    }
    
    func reset(){
        TripCriteria.reset()
        self.placeInfo = nil
        self.criteria = nil
    }
    
    func save(age: Age? = .small, gender: Gender? = .male, startDate: Int64, endDate: Int64){
        let offset = startDate.toDate.addingTimeInterval(8*60*60).milliseconds
        if endDate < offset {
            self.view?.notifyError(message: "Arrival Date should be greater than Departure Date", okAction: nil)
            return
        }
        if (criteria == nil) {
            
            self.criteria = TripCriteria(city: self.placeInfo?.place ?? "",
                                         startDate: startDate ,
                                         endDate: endDate ,
                                         gender: gender ?? .male ,
                                         age: age ?? .small)
            TripCriteria.create(criteria: criteria!)
        } else {
            criteria?.save(city: self.placeInfo?.place ?? "", startDate: startDate, endDate: endDate, gender: gender ?? Gender.both, age: age ?? .small)
        }
    }
    
    override func willDisappear() {
        super.willDisappear()
    }
}
