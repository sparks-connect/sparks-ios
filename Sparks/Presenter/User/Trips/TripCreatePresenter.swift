//
//  TripCreatePresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 09/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import NotificationBannerSwift

protocol TripCreateView: BasePresenterView {
    func navigate()
}

struct PreviewModel {
    var icon: String?
    var text: String?
}

protocol PreviewData: AnyObject{
    func getPreviewRecords(records: [PreviewModel])
}

class TripCreatePresenter: BasePresenter<TripCreateView> {
    private let service = Service.trips
    private var placeInfo: PlaceInfo?
    private var startDate: Int64 = 0
    private var endDate: Int64 = 0
    private var purpose: PurposeEnum = .leisure
    private var community: TripCommunityEnum = .alone
    private var plan: String? = ""
    weak var preview: PreviewData?
    
    func create(completion:@escaping (Bool)->Void) {
        self.service.create(city: self.placeInfo?.place ?? "",
                            lat: self.placeInfo?.coordinates?.latitude ?? 0.0,
                            lng: self.placeInfo?.coordinates?.longitude ?? 0.0,
                            purpose: self.purpose,
                            startDate: self.startDate,
                            endDate: self.endDate,
                            community: self.community,
                            plan: self.plan) { [weak self] (response) in
            completion(true)
            self?.handleResponse(response: response, preReloadHandler: {[weak self] in
                switch response {
                case .success(_):
                    self?.showBanner()
                case .failure(_):
                    break
                }
                self?.view?.navigate()
            }, reload: false)
        }
    }
    
    func showBanner(){
        let banner = GrowingNotificationBanner(title: "", subtitle:"Congratulations 🛫\nTrip was created successfully. You can check it under your profile -> My trips", style: .success)
        banner.show()
    }
    
    func preparePreview() -> [PreviewModel] {
    
        let stDate = startDate.toDate.toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
        let endDate = endDate.toDate.toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
        
        return [
            PreviewModel(icon: "icn-loc", text: self.placeInfo?.place),
            PreviewModel(icon: "icn-cal", text: "\(stDate) - \(endDate)"),
            PreviewModel(icon: "icn-purpose", text: self.purpose.getLabel()),
            PreviewModel(icon: "icn-grp", text: self.community.getLabel()),
            PreviewModel(icon: "icn-info", text: self.plan)
        ]
    }
}

extension TripCreatePresenter: TripInfo {
    func saveLocation(info: PlaceInfo?) {
        self.placeInfo = info
    }
    
    func saveDate(startDate: Int64, endDate: Int64) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func savePurpose(type: PurposeEnum) {
        self.purpose = type
    }
    
    func saveCommunity(type: TripCommunityEnum) {
        self.community = type
    }
    
    func savePlans(plan: String?) -> [PreviewModel] {
        self.plan = plan
        return self.preparePreview()
    }
}
