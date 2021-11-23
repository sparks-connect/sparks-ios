//
//  ConversationsPresenter.swift
//  cario
//
//  Created by Irakli Vashakidze on 8/29/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import Foundation
import RealmSwift

extension Channel: TableViewCellParameter {}

protocol ConversationsView: BasePresenterView {
    func reloadView(atIndexPath indexPath: IndexPath)
    func updateSection(_ section: Int, deletions: [Int], insertions: [Int], modifications: [Int])
    func updateRecievedRequestsCount()
}

enum ChannelCriteria {
    case recievedRequests
    case allRecievedRequests
    case sentRequests
    case matches
    
    var predicate: NSPredicate {
        switch self {
        case .sentRequests: return Channel.sentRequestsPredicate
        case .recievedRequests: return Channel.recievedRequestsPredicate
        case .allRecievedRequests: return Channel.allRecievedRequestsPredicate
        case .matches: return Channel.matchesPredicate
        }
    }
}

class ChannelsPresenter: BasePresenter<ConversationsView> {
    
    private var service: ChatService!
    private var dataSource: [Channel]?
    
    private var observeIdent: String?
    private var channelsToken: NotificationToken?
    private var countsToken: NotificationToken?
    private(set) var recievedRequestsCount: Int = 0
    
    private var initialLoad = true
    private(set) var criteria: ChannelCriteria = .matches
    
    var channelID : String?
    
    init(service: ChatService = Service.chat) {
        super.init()
        self.service = service
    }
    
    init(_ criteria: ChannelCriteria = .matches, service: ChatService = Service.chat) {
        super.init()
        self.criteria = criteria
        self.service = service
    }
    
    private var channelsObserveIdentifier = ""
    
    var numberOfChannels: Int {
        return self.dataSource?.count ?? 0
    }
    
    func channel(atIndexPath indexPath: IndexPath) -> Channel? {
        let count = dataSource?.count ?? 0
        guard indexPath.row < count else { return nil }
        return dataSource?[indexPath.row]
    }
    
    @discardableResult
    func channel(withID channelUID: String) -> Channel? {
        
        let channel =  dataSource?.first(where: { (channel) -> Bool in
            self.channelID == channelUID
        })
        return channel
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.observeChannels()
        self.observeRecievedRequestsCount()
    }
    
    private func observeChannels() {
        channelsToken?.invalidate()
        channelsToken = RealmUtils.observe(predicate: criteria.predicate) {[weak self] (change: RealmCollectionChange<Results<Channel>>) in
            switch change {
            case .initial(let result):
                self?.dataSource = result.sorted(by: { $0.time > $1.time })
                self?.fetchLastMessages()
                self?.view?.reloadView()
            case .update(let results, let deletions, let insertions, let modifications):
                self?.dataSource = results.sorted(by: { $0.time > $1.time })
                self?.view?.updateSection(0, deletions: deletions, insertions: insertions, modifications: modifications)
                self?.view?.reloadView()
                // TODO: updateSections doesn't work for some reasons. Maybe because of sorting.
                break
            default: break
            }
        }
    }
    
    private func observeRecievedRequestsCount() {
        countsToken?.invalidate()
        countsToken = RealmUtils.observe(predicate: ChannelCriteria.allRecievedRequests.predicate) {[weak self] (change: RealmCollectionChange<Results<Channel>>) in
            switch change {
            case .initial(let result):
                self?.recievedRequestsCount = result.count
                self?.view?.updateRecievedRequestsCount()
            case .update(let results, _, _, _):
                self?.recievedRequestsCount = results.count
                self?.view?.updateRecievedRequestsCount()
                break
            default: break
            }
        }
    }
    
    private func fetchLastMessages() {
        guard let dataSource = self.dataSource, initialLoad else { return }
        
        for channel in dataSource {
            guard !channel.isInvalidated else { continue }
            self.service.refreshHistory(channel: channel.uid, start: nil, end: nil, limit: 1, completion: nil)
        }
        
        self.initialLoad = false
    }
    
    deinit {
        channelsToken?.invalidate()
        countsToken?.invalidate()
    }
}
