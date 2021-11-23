//
//  ChatAPI.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/10/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import PubNub
import RealmSwift

// tag::EMIT-1[]
// ChatProvider.swift
class ChatEventProvider: NSObject {
    /// Defines an event received for a chat room
    ///
    /// - message:  A message sent or received on the chat room
    /// - presence: User(s) joined or left the chat room
    /// - status:   Status event of chat room
    enum ChatEvent {
        /// A message sent or received on the chat room
        case message(ChatMessageEvent)
        /// User(s) presence on the chat room changed
        case presence(ChatPresenceEvent)
        /// Chat status event or error
        case status(Result<ChatStatusEvent, Error>)
    }
    
    /// A closure executed when a chat event has been received.
    typealias Listener = (ChatEvent) -> Void
    
    /// A closure executed when the chat room changes.
    var listener: Listener?
    
    override init() {
        super.init()
    }
}

// ChatProvider.swift
protocol ChatAPI {
  /// Send a message to a chat room
    func send(_ request: ChatMessageRequest,notificationType: NotificationType, completion: @escaping (Result<ChatMessageResponse, Error>) -> Void)

  func fetchHistory(uid: String,
                    start: Int64?,
                    end: Int64?,
                    limit: UInt?,
                    reverse: Bool,
                    completion: @escaping  (Result<ChatHistoryResponse, Error>) -> Void)

  // ChatProvider.swift
  /// Get the message history of a chat room
  func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<ChatHistoryResponse?, Error>) -> Void)

// ChatProvider.swift
  /// Get the current users online in a chat room
  func presence(for roomId: String, completion: @escaping  (Result<ChatRoomPresenceResponse?, Error>) -> Void)
// end::WRAP-3[]

  /// The user sending messages
  var senderID: String { get }

  /// Start receiving changes on a chat room
  /// - parameter roomId: Identifier for the room
  /// - returns: Whether the room is currently being observed
  func subscribe(to roomId: String)
  
  /// Stop receiving changes on a chat room
  /// - parameter roomId: Identifier for the room
  func unsubscribe(from roomId: String)
  
    /// Are changes to a room currently being observed
    /// - parameter roomId: Identifier for the room
    func isSubscribed(on roomId: String) -> Bool
    
    func addListener(_ listener: ChatEventProvider)
    func removeListener(_ listener: ChatEventProvider)
    
    func updateMessage(channel: String, message: [String : Any],completion: @escaping (Result<ChatMessageResponse, Error>) -> Void)
    
    func enableNotifications(for channels: [String], token: Data, completion: @escaping (Result<Any?, Error>) -> Void)
    func disableNotifications(for channels: [String], token: Data, completion: @escaping (Result<Any?, Error>) -> Void)
}

enum NotificationType: Int {
           case spark = 1
           case message = 2
           case unlock = 3
       }

// MARK: Publish Request/Response
struct ChatMessageRequest {
    /// Identifier of room being published on
    var roomId: String
    /// Object
    var messageObject: Message
    /// Key/Value payload of the text message
    var message: [String: String]
    /// Request parameters
    var parameters: ChatPublishParameters
    
    
    init(roomId: String,
         message: Message,
         parameters: ChatPublishParameters = ChatPublishParameters())
    {
        // swiftlint:disable:previous opening_brace
        self.message = ["senderId": message.senderId,
                        "text": message.textBody,
                        BaseModelObject.BaseCodingKeys.uid.rawValue: message.uid]
        self.roomId = roomId
        self.parameters = parameters
        self.messageObject = message
    }
}

struct ChatPublishParameters {
    /// Additional information about the message
    var metadata: [String: Any]?
    /// Whether the message will be compressed prior to sending
    var compressed: Bool = false
    /// Whether the message should be stored in history
    var storeInHistory: Bool = true
    /// Content that will be attached to mobile payload
    var mobilePushPayload: [String: Any]?
}

protocol ChatMessageResponse {
    /// Updated sent `Date` from server
    var sentAt: Int64 { get }
    /// Server response message
    var responseMessage: String { get }
}

// MARK: History Request/Response
struct ChatHistoryRequest {
    /// Identifier of room being published on
    var uid: String
    /// Request parameters
    var parameters: ChatHistoryParameters
    
    init(uid: String, parameters: ChatHistoryParameters = ChatHistoryParameters()) {
        self.uid = uid
        self.parameters = parameters
    }
}

struct ChatHistoryParameters {
    /// Start `Date` value
    ///
    /// Value is exclusive, so response will include all messages after
    var start: Int64?
    /// Amount of messages returned
    var limit: UInt = 100
    /// Direction of message sentDate.
    var end: Int64?
    /// Default is true, which means timeline is traversed newest to oldest.
    var reverse: Bool = true
    /// Should dates be included in message response
    var includeTimeToken: Bool = true
}

protocol ChatHistoryResponse {
    /// Sent at `Date` value of first returned message
    var start: Int64 { get }
    /// Sent at `Date` value of last returned message
    var end: Int64 { get }
    /// Historical messages for a chat room
    var messages: [Message] { get }
}

// Presence Request/Response
protocol ChatRoomPresenceResponse {
    /// Total active users in the chat room
    var occupancy: Int { get }
    /// List of `User` identifiers active on the chat room
    var uuids: [String] { get }
}

// MARK: Listeners
protocol ChatMessageEvent {
    /// Identifier of the `ChatRoom` associated with the message
    var roomId: String { get }
    /// The message that was received
    var message: Message? { get }
}

protocol ChatPresenceEvent {
    /// Identifier of the `ChatRoom` message was recieved on
    var roomId: String { get }
    /// Total active users in the chat room
    var occupancy: Int { get }
    /// List of `User` identifiers that have joined the chat room
    var joined: [String] { get }
    /// List of `User` identifiers that have timed out on the chat room
    var timedout: [String] { get }
    /// List of `User` identifiers that have left the chat room
    var left: [String] { get }
}

enum StatusResponse: String {
    case acknowledgment
    case connected
    case reconnected
    case disconnected
    case cancelled
    case error
}

enum RequestType: String {
    case subscribe
    case unsubscribe
    
    case send
    case history
    case presence
    
    case other
}

protocol ChatStatusEvent {
    /// The status event that occurred
    var response: StatusResponse { get }
    /// The associated request for the status event
    var request: RequestType { get }
}

class ChatAPIImpl: ChatAPI {
    
    let user: User?
    init(user: User? = nil) {
        self.user = user
    }
    
    private lazy var pubnub: PubNub = {
        let config = PNConfiguration(publishKey: Consts.PubNub.publish, subscribeKey: Consts.PubNub.subscribe)
        
        if let uuid = user?.uid {
            debugPrint("Configuring PubNub with \(uuid)")
            config.uuid = uuid
        }
        
        return PubNub.clientWithConfiguration(config)
    }()
    
    func updateMessage(channel: String, message: [String : Any],completion: @escaping (Result<ChatMessageResponse, Error>) -> Void){
        pubnub.publish(message, toChannel: channel) { (status) in
            if let error = status.error {
                completion(.failure(error))
            } else {
                completion(.success(status))
            }
        }
    }
    
    // Not used right now
    func enableNotifications(for channels: [String], token: Data, completion: @escaping (Result<Any?, Error>) -> Void) {
        pubnub.addPushNotificationsOnChannels(channels, withDevicePushToken: token) { (status) in
            if let error = status.error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    // Not used right now
    func disableNotifications(for channels: [String], token: Data, completion: @escaping (Result<Any?, Error>) -> Void) {
        pubnub.removePushNotificationsFromChannels(channels, withDevicePushToken: token) { (status) in
            if let error = status.error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    func send(_ request: ChatMessageRequest,notificationType: NotificationType, completion: @escaping (Result<ChatMessageResponse, Error>) -> Void) {
        
        pubnub.publish(request.message,
                       toChannel: request.roomId,
                       mobilePushPayload: request.parameters.mobilePushPayload,
                       storeInHistory: request.parameters.storeInHistory,
                       compressed: request.parameters.compressed,
                       withMetadata: request.parameters.metadata)
        {[weak self] (status) in
            if let error = status.error {
                completion(.failure(error))
            } else {
                completion(.success(status))
                self?.sendFcmIfNeeded(request: request, notificationType: notificationType)
            }
        }
    }
    
    private func sendFcmIfNeeded(request: ChatMessageRequest, notificationType: NotificationType) {
        guard let user = User.current else { return }
        guard let channel = RealmUtils.first(type: Channel.self, request.roomId) else { return }
        
        let _tokens = channel.otherUsers.map({ $0.deviceTokensArr })
        
        let title : String?
        let messagebody : String?
        
        switch notificationType {
        case .message:
            messagebody = request.messageObject.text
            title = user.displayName
        case .spark:
            title = Consts.FirebaseCloudMessaging.newSparkTitle
            messagebody = "\(Consts.FirebaseCloudMessaging.sparkBody) \(user.displayName)"
        case .unlock:
            guard let _unlockRequestType = request.messageObject.unlockRequestType else { return }
            let messageRequst = Message.RequestType(rawValue: _unlockRequestType)
            messagebody = messageRequst?.notificationBody(userName: user.displayName)
            title = Consts.FirebaseCloudMessaging.profileUnlockRequestTitle
        }
        
                   
        var tokens = [String]()
        _tokens.forEach({ (__tokens) in
            __tokens.forEach { (token) in
                tokens.append(token)
            }
        })
      
        
        API.http.send(for: Consts.Firebase.fcmURL, method: .post,
                      params: ["registration_ids": tokens,
                                   "data": [
                                    "channelId": channel.uid,
                                    "type": notificationType.rawValue
                                   ],
                                   "notification": [
                                    "body": messagebody,
                                    "title": title,
                                    "sound": "new-message.m4r"
                                   ]
                               ],
                      headers: [ "Authorization": "Bearer \(Consts.Firebase.fcmAPIKey)" ]) { (result) in
                        switch result {
                        case .failure(let e):
                            print("Failed to send FCM: \(e)")
                            break
                        default: break
                        }
        }
    }
    
    func fetchHistory(uid: String,
                      start: Int64?,
                      end: Int64?,
                      limit: UInt?,
                      reverse: Bool = true,
                      completion: @escaping  (Result<ChatHistoryResponse, Error>) -> Void) {
        
        let lim = limit ?? 100
        let param = ChatHistoryParameters(start: start, limit: lim, end: end, reverse: reverse, includeTimeToken: true)
        let request = ChatHistoryRequest(uid: uid, parameters: param)
        
        self.history(request) { (result) in
            
            switch result {
            case .success(let resp):
                
                guard let _resp = resp else {
                    completion(.failure(CIError.invalidContent))
                    return
                }
                
                let result = HistoryResult(start: _resp.start, end: _resp.end, messages: _resp.messages)
                completion(.success(result))
                break
            default: break
            }
        }
    }
    
    func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<ChatHistoryResponse?, Error>) -> Void) {
        var startToken: NSNumber?
        if let start = request.parameters.start {
            startToken = NSNumber(value: start)
        }
        
        var endToken: NSNumber?
        if let end = request.parameters.end {
            endToken = NSNumber(value: end)
        }
        
        pubnub.historyForChannel(request.uid,
                                 start: startToken,
                                 end: endToken,
                                 limit: request.parameters.limit,
                                 reverse: request.parameters.reverse,
                                 includeTimeToken: request.parameters.includeTimeToken)
        { (result, status) in
            if let error = status?.error {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
        }
    }
    // end::WRAP-2[]
    
    // tag::WRAP-3[]
    // PubNub+ChatProvider.swift
    func presence(for roomId: String, completion: @escaping  (Result<ChatRoomPresenceResponse?, Error>) -> Void) {
        pubnub.hereNowForChannel(roomId) { (result, status) in
            if let error = status?.error {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
        }
    }
    // end::WRAP-3[]
    
    var senderID: String {
        return pubnub.uuid()
    }
    
    // tag::WRAP-4[]
    // PubNub+ChatProvider.swift
    func addListener(_ listener: ChatEventProvider) {
        pubnub.addListener(listener)
    }
    
    func removeListener(_ listener: ChatEventProvider) {
        pubnub.removeListener(listener)
    }
    
    // end::WRAP-4[]
    
    // tag::WRAP-5[]
    // PubNub+ChatProvider.swift
    func subscribe(to roomId: String) {
        pubnub.subscribeToChannels([roomId], withPresence: true)
    }
    
    func unsubscribe(from roomId: String) {
        pubnub.unsubscribeFromChannels([roomId], withPresence: true)
    }
    
    func isSubscribed(on roomId: String) -> Bool {
        return pubnub.isSubscribed(on: roomId)
    }
}

extension ChatEventProvider: PNEventsListener {
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        listener?(.message(message))
    }
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        if let error = status.error {
            listener?(.status(.failure(error)))
        } else {
            listener?(.status(.success(status)))
        }
    }
    
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        listener?(.presence(event))
    }
}
// end::EMIT-1[]

// MARK: Request Responses
extension PNPresenceChannelHereNowResult: ChatRoomPresenceResponse {
    var occupancy: Int {
        return data.occupancy.intValue
    }
    
    var uuids: [String] {
        guard let payload = data.uuids as? [[String: Any]] else {
            return []
        }
        
        return decode(payload)
    }
    
    func decode(_ payload: [[String: Any]]) -> [String] {
        
        var uuids = [String]()
        
        for item in payload {
            if let uuid = item[BaseModelObject.BaseCodingKeys.uid.rawValue] as? String {
                uuids.append(uuid)
            }
        }
        return uuids
    }
}

extension PNPublishStatus: ChatMessageResponse {
    var sentAt: Int64 {
        return data.timetoken.int64Value
    }
    
    var responseMessage: String {
        return data.information
    }
}

// tag::WRAP-1[]
// PubNub+ChatProvider.swift
extension PNHistoryResult: ChatHistoryResponse {
    // tag::ignore[]
    var start: Int64 {
        return data.start.int64Value
    }
    
    var end: Int64 {
        return data.end.int64Value
    }
    // end::ignore[]
    
    var messages: [Message] {
        guard let payload = data.messages as? [[String: Any]] else {
            return []
        }
        
        return decode(payload)
    }
    
    func decode(_ messages: [[String: Any]]) -> [Message] {
        
        var response = [Message]()
        
        for message in messages {
            guard let payload = message["message"] as? [String: String],
                let senderId = payload["senderId"],
                let timeToken = message["timetoken"] as? Int64,
                let text = payload["text"],
                // /v2/history/sub-key/{sub_key}/channel/{channel}
                let roomId = clientRequest?.url?.lastPathComponent else {
                    continue
            }
            
            
            debugPrint("message:",message)
            
            response.append(
                Message(uid: payload[BaseModelObject.BaseCodingKeys.uid.rawValue] ?? UUID().uuidString,
                        text: text,
                        sentAt: timeToken,
                        senderId: senderId,
                        roomId: roomId))
        }
        
        return response
    }
}

struct HistoryResult: ChatHistoryResponse {
    private(set) var start: Int64
    private(set) var end: Int64
    private(set) var messages: [Message]
}

// end::WRAP-1[]

// MARK: Listener Responses
extension PNMessageResult: ChatMessageEvent {
    var roomId: String {
        return data.channel
    }
    var message: Message? {
        guard let payload = data.message as? [String: Any?] else {
            return nil
        }
        
        return decode(payload)
    }
    func decode(_ payload: [String: Any?]) -> Message? {
        guard let text = payload["text"] as? String,
            let senderId = payload["senderId"] as? String else {
                return nil
        }
        
        return Message(uid: payload[BaseModelObject.BaseCodingKeys.uid.rawValue] as? String ?? UUID().uuidString,
                       text: text,
                       sentAt: data.timetoken.int64Value,
                       senderId: senderId,
                       roomId: data.channel)
    }
}

extension PNPresenceEventResult: ChatPresenceEvent {
    var roomId: String {
        return data.channel
    }
    
    var occupancy: Int {
        return data.presence.occupancy.intValue
    }
    
    var joined: [String] {
        var joined = [String]()
        if data.presenceEvent == "join", let uuid = data.presence.uuid {
            joined.append(uuid)
        }
        if let joins = data.presence.join {
            for uuid in joins {
                joined.append(uuid)
            }
        }
        
        return joined
    }
    
    var timedout: [String] {
        var timeout = [String]()
        if data.presenceEvent == "timeout", let uuid = data.presence.uuid {
            timeout.append(uuid)
        }
        
        if let timeouts = data.presence.timeout {
            for uuid in timeouts {
                timeout.append(uuid)
            }
        }
        
        return timeout
    }
    
    var left: [String] {
        var left = [String]()
        if data.presenceEvent == "leave", let uuid = data.presence.uuid {
            left.append(uuid)
        }
        if let leavers = data.presence.leave {
            for uuid in leavers {
                left.append(uuid)
            }
        }
        
        return left
    }
}

extension PNStatus: ChatStatusEvent {
    var response: StatusResponse {
        switch category {
        case .PNAcknowledgmentCategory:
            return .acknowledgment
        case .PNConnectedCategory:
            return .connected
        case .PNReconnectedCategory:
            return .reconnected
        case .PNDisconnectedCategory:
            return .disconnected
        case .PNUnexpectedDisconnectCategory:
            return .disconnected
        case .PNCancelledCategory:
            return .cancelled
        default:
            return .error
        }
    }
    
    var request: RequestType {
        switch operation {
        case .subscribeOperation:
            return RequestType.subscribe
        case .unsubscribeOperation:
            return RequestType.unsubscribe
        case .publishOperation:
            return RequestType.send
        case .historyOperation:
            return RequestType.history
        case .whereNowOperation:
            return RequestType.presence
        default:
            return RequestType.other
        }
    }
}

// ##################################


extension Date {
    /// 15-digit precision unix time (UTC) since 1970
    ///
    /// - note: A 64-bit `Double` has a max precision of 15-digits, so
    ///         any value derived from a `TimeInterval` will not be precise
    ///         enough to rely on when querying system APIs which use
    ///         17-digit precision UTC values
    var timeIntervalAsImpreciseToken: Int64 {
        return Int64(self.timeIntervalSince1970 * 10000000)
    }
    
    var milliseconds:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    func date(from millis: Double) -> Date {
        return Date(timeIntervalSince1970: millis)
    }
    
    func toString(_ format: String = "MM/dd/yy", localeIdentifier: String = Locale.current.identifier) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: localeIdentifier)
        let date = Date(timeIntervalSince1970: (TimeInterval(milliseconds)/1000))
        return dateFormatter.string(from: date)
    }
}

extension Message {
    var timeToken: NSNumber {
        return NSNumber(value: sentAt)
    }
}

extension PNStatus {
    var error: Error? {
        guard let errorStatus = self as? PNErrorStatus, errorStatus.isError else {
            return nil
        }
        
        return NSError(domain: "\(self.stringifiedOperation()) \(self.stringifiedCategory())",
            code: statusCode,
            userInfo: [
                NSLocalizedDescriptionKey: "\(self)",
                NSLocalizedFailureReasonErrorKey: errorStatus.errorData.information
        ])
    }
}



