//
//  ProfileTagsPresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 27.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol ProfileTagsView: BasePresenterView {
    func refreshTags()
}

class ProfileTagsPresenter: BasePresenter<ProfileTagsView> {
    
    private let service = Service.auth
    private let tagsService = Service.tags
    private var token: NotificationToken?
    private var userToken: NotificationToken?
    private(set) var originalDatasource: [ProfileTag] = []
    private(set) var dataSource: [ProfileTag] = []
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.tagsService.fetchTags()
        self.observeTags()
        userToken = RealmUtils.observeUserUpdates {
            self.view?.reloadView()
        }
    }
    
    private func observeTags() {
        token?.invalidate()
        token = RealmUtils.observe(sortedByKeyPath: "order", ascending: true) { [weak self] (change: RealmCollectionChange<Results<ProfileTag>>) in
            switch change {
            case .initial(let results), .update(let results, _, _, _):
                self?.originalDatasource = results.map({ $0 })
                self?.setFeaturedOnly()
                self?.view?.reloadView()
                break
            default: break
            }
        }
    }
    
    func update(indexPath: IndexPath) {
        let item = self.dataSource[indexPath.row]
        self.service.addOrRemoveInterest(item.uid, completion: { [weak self] (response) in
            self?.handleResponse(response: response)
        })
    }
    
    private func setFeaturedOnly() {
        dataSource = originalDatasource.filter({ $0.order < 5 })
    }
    
    func filter(text: String?) {
        if text?.isEmpty == true {
            setFeaturedOnly()
        } else {
            dataSource = originalDatasource.filter({ $0.name!.contains(text ?? "") })
        }
        self.view?.reloadView()
    }
    
    deinit {
        token?.invalidate()
        userToken?.invalidate()
    }
}
