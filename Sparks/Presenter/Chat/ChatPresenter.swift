//
//  ChatPresenter.swift
//  cario
//
//  Created by Irakli Vashakidze on 9/16/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import Foundation
import RealmSwift


protocol ChatViewDelegate : BasePresenterView {
    func updateSection(_ section: Int, deletions: [Int], insertions: [Int], modifications: [Int])
    func messageAdded(message:[Message])
    func popScreen()
    func updateNavBar()
    func needToCongrat()
    func scrollToBottom()
    func presentUnlockRequest()
    func channelRejected()
    func channelAccepted()
    func refreshFinished()
}

enum UnlockResponse {
    case accept
    case reject
}

extension Channel {
    var shareState: CurrentUserShareState? {
        
        var currentUserShareState: CurrentUserShareState?
        
        guard self.isAccepted else { return nil }
        
        let sharedUsers = Array(self.sharedBy)
        
        if sharedUsers.isEmpty {
            currentUserShareState = .notRequested
        }
        
        if sharedUsers.count == 1 {
            if sharedUsers.first == User.current?.uid {
                currentUserShareState = .pending
            }
            else if sharedUsers.first != User.current?.uid {
                currentUserShareState = .received
            }
        }
        if sharedUsers.count == 2 {
            currentUserShareState = .shared
        }
        
        return currentUserShareState
    }
}

class ChatPresenter: BasePresenter< ChatViewDelegate > {
    
    private var service: ChatService!
    private var chatToken: NotificationToken?
    private var channelToken: NotificationToken?
    private var channelID : String = ""
    private var once = true
    
    var channel: Channel? {
        didSet{
            self.checkProfileShareStatus()
        }
    }
    
    private var channelPredicate : NSPredicate {
        
        return NSPredicate(format: "uid == %@", channelID)
    }
    
    private(set) var messages: Results<Message>?
    
    private var start: Int64?
    private var end: Int64?
    private var limit: UInt = 20
    
    var count: Int {
        return messages?.count ?? 0
    }
    
    var isEmpty: Bool {
        return messages?.isEmpty ?? true
    }
    
    private(set) var currentUserShareState : CurrentUserShareState?
    
    init(service: ChatService = Service.chat, channelID: String?) {
        super.init()
        self.service = service
        self.channelID = channelID ?? ""
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.observeChannel()
    }
    
    func fetchHistory() {
        guard let channel = self.channel else { return }
        self.service.refreshHistory(channel: channel.uid, start: start, end: end, limit: limit) {
            main {
                self.view?.refreshFinished()
            }
        }
    }
    
    func send(text: String) {
        guard self.channelID != "" else { return }
        
        self.service.send(channelId: channelID, text: text, completion: { (response) in
            self.handleResponse(response: response)
        }) { messageResult in
            switch messageResult{
            case .success(let message):
                self.view?.messageAdded(message: [message])
            case .failure(let err):
                debugPrint(err)
            }
        }
    }
    
    private func observeChannel() {
        channelToken?.invalidate()
        channelToken = RealmUtils.observe(predicate: self.channelPredicate) {[weak self] (change: RealmCollectionChange<Results<Channel>>) in
            switch change {
            case .initial(let result):
                self?.channel = result.first
                self?.observeMessagesIfNeeded()
                self?.view?.reloadView()
            case .update(let result, let deletions, _, let modifications):
                if let index = modifications.first {
                    self?.channel = result[index]
                    self?.observeMessagesIfNeeded()
                } else if !deletions.isEmpty {
                    self?.view?.popScreen()
                }
                self?.view?.refreshFinished()
                break
            default: break
            }
        }
    }
    
    private func observeMessagesIfNeeded() {
        if self.once == true {
            self.fetchHistory()
            self.observeMessages()
            self.once = false
        }
    }
    
    func sendRequest(requestType: Message.RequestType){
        guard self.channelID != "" else {return}
        
        self.service.sendRequest(channelId: self.channelID, requestType: requestType, completion: {_ in
            
        }) {[weak self] (result) in
            
            switch result {
            case .success(let message):
                self?.channel?.save(message: message)
            case .failure(let err):
                debugPrint(err)
            }
        }
    }
    
    private func observeMessages() {
        
        guard self.channelID != "" else { return }
        
        let predicate = NSPredicate(format: "roomId == %@", self.channelID)
        
        chatToken = RealmUtils.observe(predicate: predicate,
                                       sortedByKeyPath: Message.CodingKeys.sentAt.rawValue,
                                       ascending: true) { [weak self] (change: RealmCollectionChange<Results<Message>>) in
            
            switch change {
            case .initial(let result):
                self?.messages = result
                self?.start = result.first?.timeToken.int64Value
                self?.view?.reloadView()
            case .update(let results,let deletions,let insertions,let modifications):
                main {
                    self?.messages = results
                    self?.view?.updateSection(0, deletions: deletions, insertions: insertions, modifications: modifications)
                    main(block: {
                        self?.view?.scrollToBottom()
                    }, after: 0.5)
                }
            default: break
            }
        }
    }
    
    @discardableResult func checkProfileShareStatus() -> CurrentUserShareState? {
        self.currentUserShareState = self.channel?.shareState
        self.view?.updateNavBar()
        return currentUserShareState
    }
    
    func reject() {
        
        guard let channel = self.channel else { return }
        
        Service.chat.rejectChannel(channel.uid) {[weak self] (result) in
            self?.view?.channelRejected()
        }
    }
    
    func accept() {
        guard let channel = self.channel else { return }
        Service.chat.acceptChannel(channel.uid) {[weak self] (result) in
            self?.handleResponse(response: result)
        }
    }
    
    func didRequireChannelchange(){
        if currentUserShareState == .notRequested {
            currentUserShareState = .loadingPending
            view?.updateNavBar()
            self.service.shareChannel(channelID) {[weak self] (resp) in
                self?.handleResponse(response: resp, preReloadHandler: {
                    self?.sendRequest(requestType: .shareRequested)
                    self?.view?.updateNavBar()
                }, reload: false)
            }
        } else if currentUserShareState == .received {
            self.view?.presentUnlockRequest()
        }
    }
    
    deinit {
        chatToken?.invalidate()
    }
    
    
}

extension ChatPresenter : UnlockRequestControllerDelegate{
    func didTapDecline() {
        self.sendRequest(requestType: .shareRejected)
    }
    
    func didTapAccept() {
        currentUserShareState = .loadingPending
        view?.updateNavBar()
        self.service.shareChannel(channelID) {[weak self] (resp) in
            self?.handleResponse(response: resp, preReloadHandler: {
                self?.view?.updateNavBar()
                self?.sendRequest(requestType: .shareAccepted)
            }, reload: false)
        }
        
        
    }
    
}
