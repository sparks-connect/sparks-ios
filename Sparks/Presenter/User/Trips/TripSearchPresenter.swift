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
    var criteria: TripCriteria?
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.fetchCriteria()
    }

    func getLocation(info: PlaceInfo) {
        self.placeInfo = info
        self.view?.updateLocation(text: info.place)
    }
    
    func fetchCriteria(){
        guard let criteria =  RealmUtils.fetch(TripCriteria.self).first else {
            return
        }
        self.criteria = criteria
        if self.criteria?.city.isEmpty == false {
            self.placeInfo = PlaceInfo(place: self.criteria?.city, coordinates: nil)
            self.view?.updateLocation(text: self.placeInfo?.place)
        }
        self.view?.updateView(age: Age(rawValue:self.criteria?.age ?? "") ?? .small,
                              gender: Gender(rawValue:self.criteria?.gender ?? "") ?? .male,
                              startDate: self.criteria?.startDate,
                              endDate: self.criteria?.endDate)
    }
    
    func save(age: Age? = .small, gender: Gender? = .male, startDate: Int64, endDate: Int64){
        let offset = startDate.toDate.addingTimeInterval(8*60*60).milliseconds
        if endDate > offset {
            RealmUtils.deleteAll()
            self.criteria = TripCriteria(city: self.placeInfo?.place ?? "",
                                        startDate: startDate ,
                                        endDate: endDate ,
                                        gender: gender ?? .male ,
                                        age: age ?? .small)
            RealmUtils.save(object: self.criteria ?? TripCriteria.defaultCriteria())
        }else {
            self.view?.notifyError(message: "Arrival Date should be greater than Departure Date", okAction: nil)
        }
    }
    
    func reset(){
        RealmUtils.deleteAll()
        self.placeInfo = nil
        self.criteria = nil
    }
}
