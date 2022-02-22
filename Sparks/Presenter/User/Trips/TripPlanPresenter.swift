//
//  TripPlanPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol PlanView: BasePresenterView {
    func navigate(records: [String: Any]?)
}

class TripPlanPresenter: BasePresenter<PlanView> {
    func save(info: TripInfo?, plan: String?){
        let records = info?.savePlans(plan: plan)
        self.view?.navigate(records: ["preview": records ?? []])
    }
}
