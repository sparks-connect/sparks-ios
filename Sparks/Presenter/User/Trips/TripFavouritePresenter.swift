//
//  TripFavouritePresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 23/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol TripFavView: BasePresenterView {
    func navigate(presenter: TripInfoPresenter)
}

class TripFavouritePresenter: BasePresenter<TripFavView>, ListPresenter {
    private var token: NotificationToken?
    private(set) var datasource = [Trip]()
    private let service = Service.trips

    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        observeUser()
    }
    
    override func willAppear() {
        super.willAppear()
        fetchFavourites()
    }
    
    private func observeUser() {
        token?.invalidate()
        token = RealmUtils.observeUserUpdates { [weak self] in
            main {
                self?.fetchFavourites()
            }
        }
    }
    
    private func fetchFavourites(){
        self.datasource = Array(User.current?.favourites.map({ $0 }) ?? [])
        self.view?.reloadView()
    }
    
    
    func configureCell(cell: TripCell, indexPath: IndexPath) {
        guard let user = User.current else {return}
        let trip = self.datasource[indexPath.item]
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
                       isFav: user.isTripFavourite(uid: trip.uid),
                       gender: user.genderEnum ?? .both
        )
        cell.makeFavourite = {[weak self] (indexPath) in
            self?.addToFavourite(indexPath: indexPath)
        }
    }
    
    func didSelectCell(index: Int) {
        
        let trip = self.datasource[index]
        self.view?.navigate(presenter: TripInfoPresenter(trip: trip))
    }
    
    func addToFavourite(indexPath: IndexPath) {
        guard let user = User.current else {return}
        let trip = self.datasource[indexPath.item]
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
