//
//  DiscoverPresenter.swift
//  Sparks
//
//  Created by George Vashakidze on 8/2/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import RealmSwift

protocol DiscoverView: BasePresenterView {
}

class DiscoverPresenter: BasePresenter<DiscoverView> {
    
    var predicate: NSPredicate {
        return NSPredicate(format: "status = %i AND createdBy != %@", ChannelState.requested.rawValue, User.current?.uid ?? "")
    }
    
    private var service: ChatService!
    private(set) var dataSource: [Channel]?
    
    private var observeIdent: String?
    private var channelsToken: NotificationToken?
    init(service: ChatService = Service.chat) {
        super.init()
        self.service = service
    }
    
    private var channelsObserveIdentifier = ""

    var numberOfChannels: Int {
        return self.dataSource?.count ?? 0
    }
    
    func channel(atIndexPath indexPath: IndexPath) -> Channel? {
        let count = dataSource?.count ?? 0
        guard indexPath.row >= 0, indexPath.row < count else { return nil }
        return dataSource?[indexPath.row]
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.observeChannels()
    }
    
    private func observeChannels() {
        channelsToken?.invalidate()
        channelsToken = RealmUtils.observe(predicate: self.predicate) {[weak self] (change: RealmCollectionChange<Results<Channel>>) in
            switch change {
            case .initial(let result):
                self?.dataSource = result.sorted(by: { $0.time > $1.time })
                self?.view?.reloadView()
            case .update(let results, _, _, _):
                self?.dataSource = results.sorted(by: { $0.time > $1.time })
                self?.view?.reloadView()
                break
            default: break
            }
        }
    }
    
    func remove(index: Int) {
        guard let channel = self.channel(atIndexPath: IndexPath(item: index, section: 0)) else { return }
        RealmUtils.delete(object: channel)
    }
    
    func removeLast() {
        self.remove(index: numberOfChannels - 1)
    }
    
    func reject(index: Int) {
        
        guard let channel = self.channel(atIndexPath: IndexPath(item: index, section: 0)) else { return }
        
        Service.chat.rejectChannel(channel.uid) {[weak self] (result) in
            self?.handleResponse(response: result)
        }
        
        self.remove(index: index)
    }
    
    func acceptAndSend(with index: Int, and text: String) {
        
        guard let channel = self.channel(atIndexPath: IndexPath(item: index, section: 0)) else { return }
        let uid = channel.uid
        Service.chat.acceptChannel(uid) {[weak self] (result) in
            self?.handleResponse(response: result)
            Service.chat.send(channelId: uid, text: text, completion: { (response) in
                self?.handleResponse(response: response)
            }, willSendMessage: nil)
        }
        
        remove(index: index)
    }
    
    deinit {
        channelsToken?.invalidate()
    }
}
