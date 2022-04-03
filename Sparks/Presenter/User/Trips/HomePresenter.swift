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
    //func navigate(presenter: TripInfoPresenter)
}

struct TripCollection {
    var header: String
    var trips: [Trip]
    var order: Int
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
        service.fetchNew {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let result):
                    self?.datasource.append(TripCollection(header: "Recently added", trips: result, order: 0))
                case .failure(_):
                    break
                }
            }, reload: true)
        }
        
        service.fetchUpcoming {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let result):
                    self?.datasource.append(TripCollection(header: "Upcoming", trips: result, order: 1))
                case .failure(_):
                    break
                }
            }, reload: true)
        }
        
        service.fetchInYourCity {[weak self] response in
            self?.handleResponse(response: response, preReloadHandler: {
                switch response{
                case .success(let result):
                    self?.datasource.append(TripCollection(header: "In your city", trips: result, order: 2))
                case .failure(_):
                    break
                }
            }, reload: true)
        }
        
    }
    
    var sortedDatasource: [TripCollection] {
        return self.datasource.sorted(by: { $0.order < $1.order })
    }
    
    var numberOfItems: Int {
        return datasource.count
    }
    
    func tripsAt(indexPath: IndexPath) -> TripCollection? {
        guard indexPath.row < datasource.count else { return nil }
        return sortedDatasource[indexPath.row]
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
