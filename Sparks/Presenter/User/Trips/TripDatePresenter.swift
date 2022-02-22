//
//  TripDatePresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol TripDateView: BasePresenterView {
    func navigate()
}

class TripDatePresenter: BasePresenter<TripDateView> {
    func save(info: TripInfo?, startDate: Int64, endDate: Int64){
        let offset = startDate.toDate.addingTimeInterval(8*60*60).milliseconds
        if endDate > offset {
            info?.saveDate(startDate: startDate, endDate: endDate)
            self.view?.navigate()
        }else {
            self.view?.notifyError(message: "Arrival Date should be greater than Departure Date", okAction: nil)
        }
    }
}
