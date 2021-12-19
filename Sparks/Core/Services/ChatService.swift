//
//  ChatService.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift
import FirebaseMessaging
import SDWebImage

protocol ChatService {
    func refreshHistory(channel: String, start: Int64?, end: Int64?, limit: UInt?, completion: (() -> Void)?)
    func send(channelId: String, text: String, completion:@escaping(Result<ChatMessageResponse, Error>)->Void, willSendMessage:((Result<Message, Error>)->Void)?)
    func connectToUser(_ userUid: String, completion: @escaping (Result<String, Error>) -> Void)
    func sendRequest(channelId: String, requestType: Message.RequestType, completion:@escaping(Result<ChatMessageResponse, Error>)->Void, willSendMessage:((Result<Message, Error>)->Void)?)
    
    func acceptChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void)
    func rejectChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void)
    func shareChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void)
    
    func updateShareRequest(_ channelId: String, timeToken: Int64, to: UnlockResponse ,completion: @escaping (Result<ChatMessageResponse, Error>) -> Void)
    
    func startObserveChannels()
    func stopObservingChannels()
}

typealias MessageReceivedCallback = (String, [Message]) -> Void
typealias ConnectChangedCallbak = (String, ChatRoomService.ConnectionState) -> Void
typealias ChatErrorCallback = (String, Error) -> Void

private class ChatMessageResponseImpl: ChatMessageResponse {
    var sentAt: Int64 { return 0 }
    var responseMessage: String { return "" }
}

class ChatServiceImpl: ChatService {
   
    private lazy var conversations = Set<ChatRoomService>()
    private var firebaseObserveIdentifier = ""
    private let firebase: FirebaseAPI
    private let chat: ChatAPI
    
    init(chat: ChatAPI = API.chat, firebase: FirebaseAPI = API.firebase) {
        self.chat = chat
        self.firebase = firebase
    }
    
    func startObserveChannels() {
        guard let user = User.current else { return }
        
        self.stopObservingChannels()
        
        self.firebaseObserveIdentifier = self.firebase.observeItems(type: Channel.self,
                                          at: Channel.kPath,
                                          predicates: [(Channel.CodingKeys._user_keys.rawValue, .arrayContains, user.uid)]) {[weak self] (response) in
            switch response {
            case .failure(let e):
                debugPrint("FAILED TO OBSERVE CHANNELS - \(e)")
                break
            case .success(let channels):
                self?.merge(firebaseChannels: channels)
                break
            }
        }
    }
    
    private func merge(firebaseChannels: [Channel]) {
        
        let realm = try? Realm()
        let channels = RealmUtils.fetch(Channel.self)
        
        channels.forEach { (channel) in
            if !firebaseChannels.contains(where: { $0.uid == channel.uid }) {
                try? realm?.write {
                    self.stopObservingMessages(for: channel.uid)
                    realm?.delete(channel)
                }
            }
        }
        
        firebaseChannels.forEach { (channel) in
            var object = RealmUtils.first(type: Channel.self, channel.uid)
            if object == nil {
                RealmUtils.save(object: channel)
            }
            
            object = RealmUtils.first(type: Channel.self, channel.uid)
            object?.save(channel: channel)
            
            if channel.shouldObserveMessages { // ChatRoomService internally checks if channel is subscribed or not
                
                if !self.conversations.contains(where: { $0.uid == channel.uid }) {
                    let service = ChatRoomService(for: channel.uid, with: self.chat)
                    self.conversations.insert(service)
                    service.start()
                }
                
            } else {
                self.stopObservingMessages(for: channel.uid)
            }
        }
    }
    
    private func refreshImages(channels: [Channel]) {
        channels.forEach { channel in
            channel.users.forEach { user in
                SDImageCache.shared.removeImage(forKey: user.photoUrl, fromDisk: true, withCompletion: nil)
            }
        }
    }
    
    func updateShareRequest(_ channelId: String, timeToken: Int64, to: UnlockResponse, completion: @escaping (Result<ChatMessageResponse, Error>) -> Void) {
            chat.updateMessage(channel: channelId, message: [
            "type": "update",
            "timetoken": timeToken,
            "status" : 2
            ], completion: completion)
    }
    
    func refreshHistory(channel: String, start: Int64?, end: Int64?, limit: UInt?, completion: (() -> Void)?) {
        self.chat.fetchHistory(uid: channel, start: start, end: end, limit: limit, reverse: false, completion: { response in

            switch response {
            case .success(let resp):
                let chann = RealmUtils.first(type: Channel.self, channel)
                for message in resp.messages {
                    message.user = chann?.users.first(where: { $0.uid == message.senderId })
                }
                chann?.save(messages: resp.messages)
                completion?()
            case .failure(let error):
                debugPrint("FAILED HISTORY FETCH: ", error)
                completion?()
            }
        })
    }
    
    func sendSeen(channelId: String,
                  messageId: String,
                  completion:@escaping(Result<ChatMessageResponse, Error>)->Void) {
        
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        self._send(channelId: channelId,
                   json: [Message.kLastSeen: user.uid],
                   notificationType: .message,
                   completion: completion,willSendMessage: nil)
    }
    
    func send(channelId: String,
              text: String,
              completion:@escaping(Result<ChatMessageResponse, Error>)->Void,
              willSendMessage:((Result<Message, Error>)->Void)?) {
        
        self._send(channelId: channelId,
                   json: [Consts.PubNub.kMessageBodyText: text],
                   notificationType: NotificationType.message,
                   completion: completion,willSendMessage: willSendMessage)
    }
    
    func sendRequest(channelId: String,
                     requestType: Message.RequestType,
                     completion:@escaping(Result<ChatMessageResponse, Error>)->Void,
                     willSendMessage:((Result<Message, Error>)->Void)?) {
        
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            willSendMessage?(.failure(CIError.unauthorized))
            return
        }
        
        var messageBody = [Consts.PubNub.kMessageBodyRequestType : requestType.rawValue]
        messageBody[Consts.PubNub.kMessageBodyLocation] = "\(user.lat),\(user.lng)"
        messageBody[Consts.PubNub.kMessageBodyType] = Message.MessageType.custom.rawValue
        
        self._send(channelId: channelId, json: messageBody, notificationType: .unlock, completion: completion,willSendMessage: willSendMessage)
    }
    
    private func _send(channelId: String, json: [String: Any],notificationType: NotificationType, completion:@escaping(Result<ChatMessageResponse, Error>)->Void,willSendMessage:((Result<Message, Error>)->Void)?) {
        
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            willSendMessage?(.failure(CIError.unauthorized))
            return
        }
        
        guard let string = JSONSerialization.jsonObj2Str(json) else {
            completion(.failure(CIError.invalidContent))
            willSendMessage?(.failure(CIError.invalidContent))
            return
        }
        
        let message = Message(uid: UUID().uuidString,
                              text: string,
                              sentAt: Int64(Date().timeIntervalAsImpreciseToken),
                              senderId: user.uid,
                              roomId: channelId)
        
        message.user = user
        
        let pushPayload: [String: Any]? = nil
        
        let params = ChatPublishParameters(metadata: Consts.Device.messageMetadata,
                                           compressed: true,
                                           storeInHistory: true,
                                           mobilePushPayload: pushPayload)
        
        let request = ChatMessageRequest(roomId: channelId, message: message, parameters: params)
        
        let realm = try! Realm()
        let channel = realm.object(ofType: Channel.self, forPrimaryKey: channelId)
        channel?.save(message: message)
        
        willSendMessage?(.success(message))
        
        self.chat.send(request, notificationType: notificationType) { (response) in
            main {
                switch response {
                case .failure(let error):
                    try? realm.write {
                        message.statusSetter = .failed
                    }
                    
                    channel?.save(message: message)
                    completion(.failure(MessageSendFailedError(error: error as NSError, message: message)))
                case .success(let response):
                    try? realm.write {
                        message.statusSetter = .sent
                    }
                    
                    channel?.save(message: message)
                    completion(.success(response))
                }
            }
        }
    }
    
    
    ///MARK:  Functions
    func connectToUser(_ userUid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard User.current != nil else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        firebase.callFunction(type: ConnectUserResponse.self, functionName: Consts.Firebase.apiCall_connectToUser, params: ["connectToUserId": userUid], completion: { response in
            
            switch response {
            case .success(let resp):
                guard let channelId = resp.channelId else {
                    completion(.failure(resp.error ?? CIError.unknown))
                    return
                }
                
                completion(.success(channelId))
                break
                
            case .failure(let e):
                completion(.failure(e))
                break
            }
        })
    }
    
    func acceptChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void) {
        firebase.acceptChannel(channelId, completion: completion)
    }
    
    func rejectChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void) {
        firebase.rejectChannel(channelId, completion: completion)
    }
    
    func shareChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void) {
        firebase.shareChannel(channelId, completion: completion)
    }
    
    func stopObservingChannels() {
        stopObservingMessages()
        stopObservingFirebaseChannels()
    }
    
    func stopObservingMessages() {
        self.conversations.forEach { (service) in
            service.stop()
        }
        self.conversations.removeAll()
    }
    
    func stopObservingMessages(for channelId: String) {
        guard let channel = self.conversations.first(where: { $0.uid == channelId }) else { return }
        channel.stop()
        self.conversations.remove(channel)
    }
    
    func stopObservingFirebaseChannels() {
        self.firebase.removeListener(forKey: self.firebaseObserveIdentifier)
    }
}
