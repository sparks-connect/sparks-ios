//
//  ChannelRequestsPresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 28.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol ChannelRequestsPresenterView: BasePresenterView {
    func reload(deletions: [Int], insertions: [Int], modifications: [Int])
}

class ChannelRequestsPresenter: BasePresenter<ChannelRequestsPresenterView> {
    
    private var token: NotificationToken?
    private var dataSource = [Channel]()
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        observe()
    }
    
    private func observe() {
        token = RealmUtils.observeChannelRequests(completion: {[weak self] (result, deletions, insertions, modifications) in
            
            self?.dataSource = result
            LocalStore.markChannelsSeen(result.first?.createdAt ?? 0)
            UIApplication.appDelegate?.observeChannels()
            self?.view?.reloadView()
        })
    }
    
    var numbrOfChannels: Int {
        return self.dataSource.count
    }
    
    func channel(at index: Int) -> Channel? {
        guard index < dataSource.count else { return nil }
        return dataSource[index]
    }
    
    deinit {
        token?.invalidate()
    }
}
