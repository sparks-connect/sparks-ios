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
}

class HomePresenter: BasePresenter<HomeView> {
    
    private let service = Service.trips
    private(set) var datasource: [TripCollection] = []
    private var userToken: NotificationToken?
    
    var hasSearchFilters: Bool {
        return TripCriteria.get != nil
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.fetchTrips()
        self.observeUserUpdate()
    }
    
    func fetchTrips(){
        
        self.datasource.removeAll()
        
        self.datasource.append(TripCollection(header: "Recently added", trips: []))
        self.datasource.append(TripCollection(header: "Upcoming", trips: []))
        self.datasource.append(TripCollection(header: "In your city", trips: []))
        
        let dpGroup = DispatchGroup()
        let queue = DispatchQueue.main
        dpGroup.enter()
        service.fetchNew {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let result):
                    self?.datasource[0].addTrips(trips: result)
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
    
    func refreshList() {
        self.datasource.removeAll()
        self.fetchTrips()
    }
}
