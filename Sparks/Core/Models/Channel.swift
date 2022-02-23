//
//  Channel.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 3/10/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

enum ChannelState: Int, Codable {
    case requested = 0 /// When user first sends the message - Chat has not been started yet
    case rejected = 1  /// User does not wish to chat
    case accepted = 2  /// User accepts - Chat started
    case shared = 3 /// User requests to share profiles
}

enum CurrentUserShareState {
    case notRequested // Non of users Required share
    case loadingPending // User is waiting for firebase to respond
    case pending // User is waiting for partner to share
    case received // User received share request
    case shared // Both of users shared profile
}

class Channel: BaseModelObject {
    
    @objc dynamic private(set) var read: Bool = true
    @objc dynamic private(set) var status: Int = ChannelState.requested.rawValue
    @objc dynamic private(set) var createdBy = ""
    @objc dynamic private(set) var createdAt: Int64 = 0
    @objc dynamic private(set) var senderLon: Double = 0
    @objc dynamic private(set) var senderLat: Double = 0
    @objc dynamic private(set) var unreadCount: Int = 0
    
    private var _sharedBy: [String]?
    private var _user_keys = [String]()
    private var _users: [User]?
    
    /// User who requested share
    let sharedBy = List<String>()
    /// Users which are enrolled in this channel
    let users = List<User>()
    /// Keys used to filter
    let user_keys = List<String>()
    /// Messages in this channel
    let messages = List<Message>()
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let status = try container.decode(Int?.self, forKey: .status) {
            self.status = (ChannelState(rawValue: status) ?? .requested).rawValue
        } else {
            self.status = ChannelState.requested.rawValue
        }
        
        self._sharedBy = try? container.decode([String]?.self, forKey: ._sharedBy) ?? []
        self._user_keys = try container.decode([String].self, forKey: ._user_keys)
        self._users = try container.decode([User]?.self, forKey: ._users) ?? []
        self.createdBy = try container.decode(String.self, forKey: .createdBy)
        self.createdAt = try container.decode(Int64.self, forKey: .createdAt)
        self.senderLat = (try? container.decode(Double.self, forKey: .senderLat)) ?? 0.0
        self.senderLon = (try? container.decode(Double.self, forKey: .senderLon)) ?? 0.0
    }
    
    required override init() {
        super.init()
    }
    
    private func convertSharedBy() {
        self.sharedBy.removeAll()
        self._sharedBy?.forEach { (shared) in
            self.sharedBy.append(shared)
        }
    }
    
    private func convertUserKeys() {
        self.user_keys.removeAll()
        self._user_keys.forEach { (shared) in
            self.user_keys.append(shared)
        }
    }
    
    func save(channel: Channel) {
        
        try? self.realm?.write {
            self.createdBy = channel.createdBy
            self._user_keys = channel._user_keys
            self._sharedBy = channel._sharedBy
            self._users = channel._users
            self.convertUsers()
            self.convertUserKeys()
            self.convertSharedBy()
            self.status = channel.status
            self.senderLat = channel.senderLat
            self.senderLon = channel.senderLon
            self.createdAt = channel.createdAt
            self.realm?.refresh()
        }
    }
    
    private func convertUsers() {
        
        guard let current = User.current else { return }
        self.users.removeAll()
        
        self._users?.forEach { (user) in
            if user.uid == current.uid {
                self.users.append(current)
            } else {
                if let realmUser = self.realm?.object(ofType: User.self, forPrimaryKey: user.uid) {
                    realmUser.update(user)
                    self.users.append(realmUser)
                } else {
                    self.users.append(user)
                }
            }
        }
    }
    
    func save(message: Message, bumpsUnreadCount: Bool = false) {
        guard !message.isInvalidated else { return }
        
        func bumpUnreadIfNeeded() {
            if (bumpsUnreadCount) {
                self.unreadCount += 1
            }
        }
        
        if let _ = RealmUtils.first(type: Message.self, message.uid) {
            
            try? self.realm?.write {
                bumpUnreadIfNeeded()
            }
            
            RealmUtils.save(object: message)
        } else {
            try? self.realm?.write {
                bumpUnreadIfNeeded()
                self.messages.append(message)
            }
        }
    }
    
    func resetUnreadCount() {
        if self.realm?.isInWriteTransaction == true {
            self.unreadCount = 0
        } else {
            try? self.realm?.write {
                self.unreadCount = 0
            }
        }
        
    }
    
    func save(messages: [Message]) {
        try? self.realm?.write {
            for message in messages {
                if !message.isInvalidated {
                    if let _ = RealmUtils.first(type: Message.self, message.uid) {
                        realm?.add(message, update: .modified)
                    }
                    
                    self.messages.append(message)
                }
            }
        }
    }
    
    func markAsRead() {
        try? self.realm?.write {
            self.read = true
        }
    }
    
    var isProfileShared: Bool {
        return sharedBy.count == 2
    }
    
    enum CodingKeys: String, CodingKey {
        case _sharedBy = "sharedBy", status, _users = "users", _user_keys = "user_keys", createdBy, createdAt, senderLat, senderLon
    }
    
    var lastMessage: Message? {
        return self.messages.max(by: { $0.sentAt < $1.sentAt })
    }
    
    var distance: String {
        let user = User.current!
        let myLocation = CLLocation(latitude: user.lat, longitude: user.lng)
        let othersLocation = CLLocation(latitude: self.senderLat, longitude: self.senderLon)
        
        return distanceStr(between: myLocation, location2: othersLocation)
    }
    
    static let kPath = "channels"
}

extension Channel {
    var otherUsers: [User] {
        return self.users.filter({ $0.uid != User.current?.uid })
    }
    
    var shouldObserveMessages: Bool {
        return self.statusEnum.rawValue >= ChannelState.accepted.rawValue
    }
    
    var statusEnum: ChannelState {
        get {
            return ChannelState(rawValue: status) ?? .requested
        }
    }
    
    var recipientPhotoURL: String? {
        return self.otherUsers.first?.photoUrl
    }
    
    var recipientDisplayName: String? {
        return self.otherUsers.first?.displayName
    }
    
    var text: String? {
        guard let message = self.lastMessage else { return nil }
        return message.isRegularMessage ? message.text : message.requestType?.desc
    }
    
    var time: Int64 {
        return self.lastMessage?.sentAt ?? 0
    }
    
    var latitude: Double {
        return lastMessage?.lat ?? 0
    }
    
    var longitude: Double {
        return lastMessage?.lng ?? 0
    }
    
    var lastMessageTimeHumanized: String? {
        guard self.time > 0 else { return nil }
        let timeInterval = TimeInterval(integerLiteral: self.time / 10000)
        let date = Date(timeIntervalSince1970: timeInterval / 1000)
        return date.toRelativeDateString()
    }
    
    var isMyChannel: Bool {
        return self.createdBy == User.current?.uid
    }
    
    var isRequested: Bool {
        return self.statusEnum == .requested
    }
    
    var isAccepted: Bool {
        return self.statusEnum == .accepted
    }
}

extension Channel {
    static var matchesPredicate: NSPredicate {
        return NSPredicate(format: "status > %i", ChannelState.rejected.rawValue)
    }
    
    static var recievedRequestsPredicate: NSPredicate {
        return NSPredicate(format: "createdBy != %@ AND status == %i",
                           User.current?.uid ?? "",
                           ChannelState.requested.rawValue)
    }
    
    static var allRecievedRequestsPredicate: NSPredicate {
        return NSPredicate(format: "createdBy != %@ AND status == %i",
                           User.current?.uid ?? "",
                           ChannelState.requested.rawValue)
    }
    
    static var sentRequestsPredicate: NSPredicate {
        let time = LocalStore.lastRecievedChannelRequestTime
        return NSPredicate(format: "createdBy == %@ AND status == %i AND createdAt > \(time)",
                           User.current?.uid ?? "",
                           ChannelState.requested.rawValue)
    }
    
    static func observeUnreadCounts(_ completion:@escaping(Int) -> Void) -> NotificationToken? {
        return RealmUtils.observe(predicate: ChannelCriteria.matches.predicate) { (change: RealmCollectionChange<Results<Channel>>) in
            switch change {
            case .initial(let result):
                completion(result.map({$0.unreadCount}).reduce(0, +))
                break
            case .update(let result, _, _, _):
                completion(result.map({$0.unreadCount}).reduce(0, +))
                break
            default: break
            }
        }
    }
    
}
