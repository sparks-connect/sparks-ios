//
//  TripListPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol TripListView: BasePresenterView {
    func navigate(presenter: TripInfoPresenter)
}

class TripListPresenter: BasePresenter<TripListView> {
    private let service = Service.trips
    var datasource: [Trip]?
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.fetchTrips()
    }
    
    func fetchTrips(){
        service.fetch(startDate: nil, randomQueryInt: nil, limit: 10) {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let model):
                    self?.datasource = model.trips
                case .failure(_):
                    break
                }
            }, reload: true)
        }
    }
    
    func configureCell(cell: TripCell, indexPath: IndexPath){
        guard let trip = self.datasource?[indexPath.item] else {return}
        
        let stDate = trip.startDate.toDate.toString("dd MMM", localeIdentifier: Locale.current.identifier)
        let endDate = trip.endDate.toDate.toString("dd MMM", localeIdentifier: Locale.current.identifier)
        let date = "\(stDate) - \(endDate)"
        let profile = "\(trip.user?.firstName ?? ""), \(trip.user?.ageYear ?? 0)"
        
        cell.configure(url: trip.user?.photoUrl ?? "",
                       date: date,
                       name: profile,
                       location: trip.city ?? "",
                       desc: trip.plan ?? "")
    }
    
    func didSelectCell(index: Int) {
        guard let trip = self.datasource?[index] else {return}
        self.view?.navigate(presenter: TripInfoPresenter(trip: trip))
    }
}
