//
//  ProfilePresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 05.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol MyProfileView: BasePresenterView {

}

class ProfilePresenter: BasePresenter<MyProfileView> {
    
    private var token: NotificationToken?
    let itemsPerRow: CGFloat = 3
    private(set) lazy var selectedIndexPaths = [IndexPath]()
    private lazy var photos = [UserPhoto]()
    private let service = Service.trips
    private lazy var trips = [Trip]()
    var user = User.current
    var isCurrentUser: Bool {
        return self.user == User.current
    }
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        observeUser()
        getMyTrips()
    }
    
    convenience init(user: User) {
        self.init()
        self.user = user
    }
    
    private func observeUser() {
        token?.invalidate()
        token = RealmUtils.observeUserUpdates {
            self.photos = self.user?.photos.filter({ !$0.main }) ?? []
            self.getMyTrips()
            self.view?.reloadView()
        }
    }
    
    var numberOfTrips: Int {
        return trips.count
    }
    
    var numberOfChannels: Int {
        let channels = RealmUtils.fetch(Channel.self, nsPredicate: Channel.matchesPredicate)
        return channels.count
    }
    
    var numberOfItems: Int {
        return photos.count
    }
    
    func photo(atIndexPath indexPath: IndexPath) -> UserPhoto? {
        guard indexPath.row < numberOfItems else { return nil }
        return photos[indexPath.row]
    }
    
    func selectItem(at indexPath: IndexPath) {
        if let index = self.selectedIndexPaths.firstIndex(where: { $0 == indexPath }) {
            self.selectedIndexPaths.remove(at: index)
        } else {
            self.selectedIndexPaths.append(indexPath)
        }
    }
    
    var selectedPostIds: [String] {
        guard let user = self.user else { return [] }
        var result = [String]()
        for indexPath in selectedIndexPaths {
            guard indexPath.row < numberOfItems else { continue }
            result.append(user.photos[indexPath.row].uid)
        }
        return result
    }
    
    func uploadImage(image: UIImage, isMain: Bool) {
        guard let data = image.compressed else { return }
        self.auth.updatePhoto(data: data, main: isMain) { [weak self] (response) in
            self?.handleResponse(response: response)
        }
    }
    
    func deletePhoto(photo: UserPhoto) {
        self.auth.deletePhoto(photo: photo) { [weak self] response in
            self?.handleResponse(response: response)
        }
    }
    
    func getMyTrips() {
        if self.isCurrentUser {
            service.fetchMyTrips() { [weak self] (response) in
                self?.handleResponse(response: response, preReloadHandler: {
                    switch response {
                    case .success(let trips):
                        self?.trips = trips
                    case .failure(_): break
                    }
                })
            }
        }else {
            service.fetchTripsForUser(uid: self.user?.uid  ?? "") { [weak self] (response) in
                self?.handleResponse(response: response, preReloadHandler: {
                    switch response {
                    case .success(let trips):
                        self?.trips = trips
                    case .failure(_): break
                    }
                })
            }
        }
    }
    
    deinit {
        token?.invalidate()
        token = nil
    }
}
