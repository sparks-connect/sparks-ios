//
//  TripPreviewPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 05/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol PreviewView: BasePresenterView {
   func navigate()
}

class TripPreviewPresenter: BasePresenter<PreviewView> {
    private let service = Service.trips

    func create() {
        self.service.create(city: "Viana, Austrailia",
                            lat: 24.2322,
                            lng: 46.2322,
                            purpose: .leisure,
                            startDate: 12331,
                            endDate: 123231,
                            community: .alone,
                            plan: "I have many plans ..") { [weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.navigate()
            }, reload: false)
        }
    }
}
