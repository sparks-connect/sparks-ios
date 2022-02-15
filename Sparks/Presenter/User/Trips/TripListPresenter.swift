//
//  TripListPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol TripListView: BasePresenterView {
    func navigate(presenter: TripInfoPresenter)
}

class TripListPresenter: BasePresenter<TripListView> {
    private let service = Service.trips
    var datasource: [Trip]?
    private var token: NotificationToken?
    private var startDate: Int64?;
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.observePredicate()
    }
    
    func fetchTrips(){
        service.fetch(startDate: self.startDate, limit: 10) {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let model):
                    self?.datasource = model.trips
                    self?.startDate = model.nextStartDate
                case .failure(_):
                    break
                }
            }, reload: true)
        }
    }
    
    private func observePredicate() {
        token?.invalidate()
        token = RealmUtils.observe {[weak self] (change: RealmCollectionChange<Results<TripCriteria>>) in
            switch change {
            case .initial(let results):
                self?.startDate = results.first?.startDate
                self?.fetchTrips()
            case .update(let results,_,_,_):
                self?.startDate = results.first?.startDate
                self?.fetchTrips()
                break
            default: break
            }
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
