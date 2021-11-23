//
//  MyProfilePresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 05.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol MyProfileView: BasePresenterView {

}

class MyProfilePresenter: BasePresenter<MyProfileView> {
    
    private var token: NotificationToken?
    let itemsPerRow: CGFloat = 3
    private(set) lazy var selectedIndexPaths = [IndexPath]()
    private lazy var photos = [UserPhoto]()
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        observeUser()
    }
    
    private func observeUser() {
        token?.invalidate()
        token = RealmUtils.observeUserUpdates {
            self.photos = User.current?.photos.filter({ !$0.main }) ?? []
            self.view?.reloadView()
        }
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
        guard let user = User.current else { return [] }
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
}
