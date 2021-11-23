//
//  ChatRoomServi e.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 4/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import PubNub
import RealmSwift

//MARK: ############################## ChatRoomService ##############################

class ChatRoomService: NSObject {
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ChatRoomService else { return false }
        return object.uid == self.uid
    }

// tag::ignore[]
  // MARK: Types
  /// Tuple containing UUIDs for users that have `joined` and `left` chat
  typealias PresenceChange = (uid: String, joined: [String], left: [String])

  /// Defines the connection state of a chat room
  ///
  /// - connected:    Chat room is connection and emitting events
  /// - notConnected: Chat room is not connected and no longer active
  enum ConnectionState {
    /// Chat room is connection and emitting events
    case connected
    /// Chat room is not connected and no longer active
    case notConnected
  }


    struct MessageEvent {
        private(set) var uid: String
        private(set) var messages:[Message]
    }
    
    typealias ConnectionStateChange = (uid: String, connectionState: ConnectionState)
    
  /// Defines an event received for a chat room
  ///
  /// - message:  A message sent or received on the chat room
  /// - presence:    User(s) joined or left the chat room
  /// - status:   Status event of chat room
  enum ChatRoomEvent {
    
    /// A message sent or received on the chat room
    case messages(Result<MessageEvent, Error>)
    /// User(s) presence on the chat room changed
    case presence(Result<PresenceChange, Error>)
    /// Status event of chat room
    case status(Result<ConnectionStateChange, Error>)
  }

  typealias Listener = (ChatRoomEvent) -> Void

  // MARK: Public Properties
  /// A closure executed when the chat room changes.
  var listener: Listener?

  private(set) var uid: String = ""

  // MARK: Private Properties
  private var chatProvider: ChatAPI!

  private var _occupantUUIDs = Set<String>()
  private var _messages = [Message]()

  // MARK: Private Queues
  private let presenceQueue = DispatchQueue(label: "ChatRoomService Presence Queue",
                                            qos: .userInitiated, attributes: .concurrent)
  private let eventQueue = DispatchQueue(label: "ChatRoomService Event Queue")

  private let historyRequestQueue = DispatchQueue(label: "ChatRoomService History Request Queue")
  private let historyRequestGroup = DispatchGroup()
  private let eventEmitter = ChatEventProvider()
    
// end::ignore[]
  init(for uid: String,
       with provider: ChatAPI) {
    
    super.init()
    
    self.uid = uid
    self.chatProvider = provider
  }
  
  deinit {
    chatProvider.unsubscribe(from: uid)
    chatProvider.removeListener(eventEmitter)
  }

  // MARK: - Thread Safe Collections
  /// List of `User` identifiers that are connected to the chat room
  var occupantUUIDs: [String] {
    var users = Set<String>()

    presenceQueue.sync {
      users = self._occupantUUIDs
    }

    return Array(users)
  }

  /// Total users connected to the chat room
  var occupancy: Int {
    return occupantUUIDs.count
  }

  /// Connection state of the chat room
  var state: ConnectionState {
    return chatProvider.isSubscribed(on: uid) ? .connected : .notConnected
  }

// MARK: - Service Stop/Start
  /// Connects to, and starts listening for changes on, the chat room.
  func start() {
    if !chatProvider.isSubscribed(on: uid) {
        chatProvider.subscribe(to: uid)
        
        self.chatProvider.addListener(eventEmitter)
    
        // Enable the chat listener
        self.eventEmitter.listener = { [weak self] (event) in
            switch event {
            case .message(let message):
                self?.didReceive(message: message)
            case .presence(let event):
                self?.didReceive(presence: event)
            case .status(let result):
                switch result {
                case .success(let event):
                    NotificationCenter.default.post(name: Consts.Notifications.connectionChanged, object: event)
                    break
                default: break
                }
                self?.didReceive(status: result)
            }
        }
    }
  }

  /// Disconnects from, and stops listening for changes on, the chat room.
    func stop() {
        chatProvider.unsubscribe(from: uid)
        self.chatProvider.removeListener(eventEmitter)
        self.eventEmitter.listener = nil
    }

    func isSubscribed() -> Bool {
        return chatProvider.isSubscribed(on: uid)
    }
// MARK: - Public Methods
// ChatService.swift
  /// Send a message to the service's chat room
  /// - parameter text: The text to be published
    func send(_ text: String, metadata: ChatPublishParameters, completion: @escaping (Result<Message, Error>) -> Void) {
        let sentAtValue = Date().timeIntervalAsImpreciseToken

        let message = Message(uid: UUID().uuidString,
                              text: text,
                              sentAt: sentAtValue,
                              senderId: chatProvider.senderID,
                              roomId: uid)

        let request = ChatMessageRequest(roomId: uid, message: message, parameters: metadata)

        self.chatProvider.send(request, notificationType: .spark) { (result) in
          switch result {
          case .success:
            completion(.success(message))
          case .failure(let error):
            completion(.failure(error))
          }
        }
    }

  // MARK: Event Listeners
  /// Processes messages received on the chat room
  private func didReceive(message response: ChatMessageEvent) {
    guard let message = response.message else {
      debugPrint("Error: Received Message Event missing message body")
      return
    }

    let event = MessageEvent(uid: message.roomId, messages: [message])
    
    let realm = try? Realm()
    for message in event.messages {
        let messageChannel = realm?.object(ofType: Channel.self, forPrimaryKey: message.roomId)
        message.user = messageChannel?.users.first(where: { $0.uid == message.senderId })
        messageChannel?.save(message: message)
    }
    
    self.emit(.messages(.success(event)))
  }

  /// Processes status changes received on the chat room
  private func didReceive(status event: Result<ChatStatusEvent, Error>) {
    switch event {
    case .success(let status):
      debugPrint("Status Change Received: \(status.response)")

      switch status.response {
      case .connected, .reconnected:
        presenceQueue.async(flags: .barrier) { [weak self] in
          if let senderID = self?.chatProvider.senderID {
            self?._occupantUUIDs.insert(senderID)
          }

            self?.emit(.status(.success((self?.uid ?? "", .connected))))
        }
      case .disconnected:
        // Clear Occupancy
        presenceQueue.async(flags: .barrier) { [weak self] in
          self?._occupantUUIDs.removeAll()

          self?.emit(.status(.success((self?.uid ?? "", .notConnected))))
        }
      default:
        debugPrint("Category \(status.response) was not processed.")
      }

    case .failure(let error):
      debugPrint("Error Status Change Received: \(error)")
      emit(.status(.failure(error)))
    }
  }

  /// Processes user presence changes received on the chat room
  private func didReceive(presence response: ChatPresenceEvent) {
    debugPrint("Presence Change Received: \(response.occupancy)")
    presenceQueue.async(flags: .barrier) { [weak self] in

      for uuid in response.joined {
        self?._occupantUUIDs.insert(uuid)
      }
      for uuid in response.timedout {
        self?._occupantUUIDs.remove(uuid)
      }
      for uuid in response.left {
        self?._occupantUUIDs.remove(uuid)
      }

      self?.emit(.presence(.success((self?.uid ?? "", response.joined, response.timedout+response.left))))
    }
  }

  // MARK: - Private Methods
  private func emit(_ event: ChatRoomEvent) {
    eventQueue.async { [weak self] in
      self?.listener?(event)
    }
  }
}
