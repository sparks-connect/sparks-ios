//
//  Message.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/4/19.
//

import Foundation
import MessageKit

class Message: BaseModelObject, MessageType {
    
    enum MessageStatus: Int, Codable {
        case sent = 1
        case failed = 2
        case delivered = 3
        case seen = 4
    }
    
    enum RequestType : String {
        case shareRequested = "3" /// User requests to share profiles
        case shareRejected = "4" /// User rejects share profile request
        case shareAccepted = "5" /// User accepts share prodile request
        
        func notificationBody(userName: String) -> String {
            switch self {
            case .shareRequested: return "\(userName) sent you unlock request"
            case .shareRejected: return "\(userName) declined your unlock request"
            case .shareAccepted: return "You and \(userName) are now unlocked"
            }
        }
        
        var desc: String {
            switch self {
            case .shareRequested: return "Profile share requested"
            case .shareRejected: return "Profile share rejected"
            case .shareAccepted: return "Profile share accepted"
            }
        }
    }
    
    private var bodyCache: [String: String]?
    private var body: [String: String]? {
        guard let cached = self.bodyCache else {
            self.bodyCache = JSONSerialization.str2Dictionary(textBody) as? [String: String]
            return self.bodyCache
        }
        
        return cached
    }
    
    enum MessageType : String {
      case custom
      case text
    }
    
    var kind: MessageKind {
        guard let body = self.body,
                let typeStr = body[Consts.PubNub.kMessageBodyType],
                    let type = MessageType(rawValue: typeStr)  else {
            return .text(self.text ?? "")
        }
        
        switch type{
        case .custom:
            return .custom(body)
        case .text:
            return .text(self.text ?? "")
        }
    }
   
    /// The text content for the message
    @objc dynamic private(set) var textBody: String = ""
    
    /// 17-digit precision unix time (UTC) when message was sent
    @objc dynamic var sentAt: Int64 = 0
    /// Identifier of the user who sent the message
    @objc dynamic var senderId: String = ""
    /// Identifier of the room to which the message belongs
    @objc dynamic var roomId: String = ""
      /// Identifier of the message delievery status
    @objc dynamic private var status: Int = MessageStatus.sent.rawValue
    
    var statusSetter: MessageStatus {
        get { return MessageStatus(rawValue: status)! }
        set { status = newValue.rawValue }
    }
    
    var user: User! = nil
    
    var lastSeen: String? {
        return self.body?[Message.kLastSeen]
    }
    
    var messageId: String {
        return uid
    }
    
    var sender: SenderType {
        return self.user ?? User(uid: senderId, firstName: "Anonymous", lastName: "Lamb")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.textBody = try container.decode(String.self, forKey: .textBody)
        self.sentAt = try container.decode(Int64.self, forKey: .sentAt)
        self.senderId = try container.decode(String.self, forKey: .senderId)
        self.roomId = try container.decode(String.self, forKey: .roomId)
        if let intStatus = try? container.decodeIfPresent(Int.self, forKey: .status) {
            status =  intStatus
        }
    }
    
    init(uid: String, text: String, sentAt: Int64, senderId: String, roomId: String, status: MessageStatus = .sent) {
        super.init()
        self.uid = uid
        self.textBody = text
        self.sentAt = sentAt
        self.senderId = senderId
        self.roomId = roomId
        self.statusSetter = status
    }
    
    required override init() {
        super.init()
    }
    
    var text: String? {
        return body?[Consts.PubNub.kMessageBodyText]
    }
    
    var unlockRequestType: String? {
         return body?[Consts.PubNub.kMessageBodyRequestType]
    }
    
    var lat: Double {
        guard let location = body?[Consts.PubNub.kMessageBodyLocation],
            let str = location.components(separatedBy: ",").first else { return 0 }
        return Double(str) ?? 0
    }
    
    var lng: Double {
        guard let location = body?[Consts.PubNub.kMessageBodyLocation],
            let str = location.components(separatedBy: ",").last else { return 0 }
        return Double(str) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case textBody, sentAt, senderId, roomId, status
    }
    
    static let kLastSeen = "lastSeen"
}

extension Message {
    var sentDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(integerLiteral: sentAtInSeconds))
    }
    
    var sentAtInSeconds: Int64 {
        return sentAt/10000000
    }
}

struct MessageContent {
    private(set) var mentions: [String]
    private(set) var emoticons: [String]
    private(set) var links: [String]
    private(set) var hashtags: [String]
}

extension Message {
    func extract() -> MessageContent {
        let allExtractedEntities = try? ContentAnalyser.extractEntitiesWithIndices(from: text)
        
        let extractedMentions = allExtractedEntities?.filter { $0.type == .mention }.map { $0.value } ?? []
        let extractedEmoticons = allExtractedEntities?.filter { $0.type == .emoticon }.map { $0.value } ?? []
        let extractedLinks = allExtractedEntities?.filter { $0.type == .url }.map { $0.value } ?? []
        let extractedHashtags = allExtractedEntities?.filter { $0.type == .hashtag }.map { $0.value } ?? []
        
        return MessageContent(mentions: extractedMentions, emoticons: extractedEmoticons, links: extractedLinks, hashtags: extractedHashtags)
    }
}


extension Message {
    var requestType : RequestType? {
        guard let typeStr = body?[Consts.PubNub.kMessageBodyRequestType] else { return nil }
        return RequestType(rawValue: typeStr)
    }
    
    var isRegularMessage: Bool {
        return self.requestType == nil
    }
}
