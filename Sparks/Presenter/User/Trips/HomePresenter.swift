//
//  HomePresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 01.04.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol HomeView: BasePresenterView {
    func showLoader(isLoading: Bool)
}

struct TripCollection {
    var header: String
    var trips: [Trip]
    
    mutating func addTrips(trips: [Trip]) {
        self.trips.append(contentsOf: trips)
    }
    
    mutating func setHeader(header: String) {
        self.header = header
    }
}

class HomePresenter: BasePresenter<HomeView> {
    
    private let service = Service.trips
    private(set) var datasource: [TripCollection] = []
    private var userToken: NotificationToken?
    private var firstLoad = true
    
    var hasSearchFilters: Bool {
        return TripCriteria.get != nil
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.fetchTrips()
        self.observeUserUpdate()
    }
    
    override func willAppear() {
        super.willAppear()
        if firstLoad {
            self.view?.showLoader(isLoading: true)
            firstLoad = false
        }
    }
    
    func fetchTrips(){
        self.datasource.removeAll()
        
        self.datasource.append(TripCollection(header: "Loading ...", trips: []))
        self.datasource.append(TripCollection(header: "", trips: []))
        self.datasource.append(TripCollection(header: "", trips: []))
        
        let dpGroup = DispatchGroup()
        let queue = DispatchQueue.main
        dpGroup.enter()
        service.fetchNew {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let result):
                    self?.datasource[0].addTrips(trips: result)
                    self?.datasource[0].setHeader(header: "Recently added")
                case .failure(_):
                    break
                }
                queue.async { dpGroup.leave() }
                
            }, reload: false)
        }
        
        dpGroup.enter()
        service.fetchUpcoming {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let result):
                    self?.datasource[1].addTrips(trips: result)
                    self?.datasource[1].setHeader(header: "Upcoming")
                case .failure(_):
                    break
                }
                queue.async { dpGroup.leave() }
            }, reload: false)
        }
        
        dpGroup.enter()
        service.fetchInYourCity {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let result):
                    self?.datasource[2].addTrips(trips: result)
                    self?.datasource[2].setHeader(header: "In your city")
                case .failure(_):
                    break
                }
                queue.async { dpGroup.leave() }
            }, reload: false)
        }
        
        dpGroup.notify(queue: queue, execute: {[weak self] in
            self?.view?.reloadView()
        });
    }
    
    var numberOfItems: Int {
        return datasource.count
    }
    
    func tripsAt(indexPath: IndexPath) -> TripCollection? {
        guard indexPath.row < datasource.count else { return nil }
        return datasource[indexPath.row]
    }
    
    private func observeUserUpdate() {
        userToken?.invalidate()
        userToken = RealmUtils.observeUserUpdates {[weak self] in
            self?.view?.reloadView()
        }
    }
    
    func addToFavourite(trip: Trip) {
        guard let user = User.current else {return}
        
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
    
    func refreshList() {
        self.datasource.removeAll()
        self.fetchTrips()
    }
}
