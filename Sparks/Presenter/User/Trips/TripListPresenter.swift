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
    func showLoader(isLoading: Bool)
    func navigate(presenter: TripInfoPresenter)
}

class TripListPresenter: BasePresenter<TripListView>, ListPresenter {
    private let service = Service.trips
    var datasource: [Trip]?
    private var token: NotificationToken?
    private var userToken: NotificationToken?
    private var lastItem: Any?
    private var loadMore: Bool {
        return lastItem != nil
    }
    var hasSearchFilters: Bool {
        return TripCriteria.get != nil
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.observePredicate()
        self.observeUserUpdate()
    }
    
    func fetchTrips(_ showLoader: Bool = true){
        
        self.view?.showLoader(isLoading: showLoader)
        service.fetch(limit: 5, lastItem: lastItem){[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let model):
                    if self?.lastItem == nil {
                        self?.datasource = model.trips
                    }else {
                        self?.datasource?.append(contentsOf: model.trips)
                    }
                    self?.lastItem = model.lastItem
                case .failure(_):
                    break
                }
            }, reload: true)
        }
    }
    
    private func observePredicate() {
        token?.invalidate()
        token = RealmUtils.observe {[weak self] (change: RealmCollectionChange<Results<TripCriteria>>) in
            main {
                switch change {
                case .initial(_):
                    self?.fetchTrips()
                case .update(_,_,_,_):
                    self?.fetchTrips()
                    break
                default: break
                }
            }
        }
    }
    
    private func observeUserUpdate() {
        userToken?.invalidate()
        userToken = RealmUtils.observeUserUpdates {[weak self] in
            self?.view?.reloadView()
        }
    }
    
    func configureCell(cell: TripCell, indexPath: IndexPath){
        guard let user = User.current, let trip = self.datasource?[indexPath.item] else {return}
        
        let stDate = trip.startDate.toDate.toString("dd MMM", localeIdentifier: Locale.current.identifier)
        let endDate = trip.endDate.toDate.toString("dd MMM", localeIdentifier: Locale.current.identifier)
        let date = "\(stDate) - \(endDate)"
        let profile = "\(trip.user?.firstName ?? ""), \(trip.user?.ageYear ?? 0)"
        
        cell.configure(indexPath: indexPath,
                       url: trip.user?.photoUrl ?? "",
                       date: date,
                       name: profile,
                       location: trip.city ?? "",
                       desc: trip.plan ?? "",
                       isFav: user.isTripFavourite(uid: trip.uid)
                    )
        cell.makeFavourite = {[weak self] (indexPath) in
            self?.addToFavourite(indexPath: indexPath)
        }
    }
    
    func refreshList() {
        self.lastItem = nil
        self.fetchTrips(false)
    }
    
    func fetchNextPage() {
        if self.lastItem != nil {
            self.fetchTrips(false)
        }
    }
    
    func didSelectCell(index: Int) {
        guard let trip = self.datasource?[index] else {return}
        self.view?.navigate(presenter: TripInfoPresenter(trip: trip))
    }
    
    func addToFavourite(indexPath: IndexPath) {
        guard let user = User.current, let trip = self.datasource?[indexPath.item] else {return}
        if user.isTripFavourite(uid: trip.uid) {
            service.removeFromFavourites(uid: trip.uid) { result in
                switch result {
                case .failure(let e):
                    debugPrint(e)
                    break
                default: break
                }
            }
        } else {
            service.addToFavourites(trip: trip) { result in
                switch result {
                case .failure(let e):
                    debugPrint(e)
                    break
                default: break
                }
            }
        }
        
    }
}
