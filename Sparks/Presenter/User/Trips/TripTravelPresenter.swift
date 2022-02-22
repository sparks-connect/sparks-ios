//
//  TripTravelPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol TravelView: BasePresenterView {
    func navigate()
}

class TripTravelPresenter: BasePresenter<TravelView> {
    func save(info: TripInfo?, community: TripCommunityEnum){
        info?.saveCommunity(type: community)
        self.view?.navigate()
    }
}
