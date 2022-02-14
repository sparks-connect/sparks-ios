//
//  TripInfoPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol TripInfoView: BasePresenterView {
    func loadImage(url: URL?)
    func navigate()
}

class TripInfoPresenter: BasePresenter<TripInfoView>, PreviewConfiguration {
    var trip: Trip!
    var data: [PreviewModel]?{
        return self.preparePreview()
    }

    convenience init(trip: Trip){
        self.init()
        self.trip = trip
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        let url = URL(string: self.trip.user?.photoUrl ?? "")
        self.view?.loadImage(url: url)
    }
    
    func preparePreview() -> [PreviewModel] {
        
        let stDate = self.trip.startDate.toDate.toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
        let endDate = self.trip.endDate.toDate.toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
        
        let purpose = PurposeEnum(rawValue: self.trip.purpose) ?? .leisure
        let community = TripCommunityEnum(rawValue: self.trip.community) ?? .alone

        return [
            PreviewModel(icon: "icn-loc", text: self.trip.city),
            PreviewModel(icon: "icn-cal", text: "\(stDate) - \(endDate)"),
            PreviewModel(icon: "icn-purpose", text: purpose.getLabel()),
            PreviewModel(icon: "icn-grp", text: community.getLabel()),
            PreviewModel(icon: "icn-info", text: self.trip.plan)
        ]
    }
    
    func configure(cell: PreviewCell, indexPath: IndexPath){
        guard let model = self.data?[indexPath.row] else {return}
        cell.configure(icn: model.icon, text: model.text)
    }
    
}
