//
//  ServiceProvider.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/13/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

class Service {

    private static let instance = Service()

    let auth: UserService
    let chat: ChatService
    let tags: TagsService
    let trips: TripsService
    
    private init() {
        auth = UserServiceImpl(api: API.firebase)
        chat = ChatServiceImpl(chat: API.chat, firebase: API.firebase)
        tags = TagsServiceImpl(firebase: API.firebase)
        trips = TripsServiceImpl(firebase: API.firebase)
    }

    class var auth: UserService {
        return instance.auth
    }

    class var chat: ChatService {
        return instance.chat
    }
    
    class var tags: TagsService {
        return instance.tags
    }
    
    class var trips: TripsService {
        return instance.trips
    }
    
    class func logout() {
        auth.logout()
        chat.stopObservingChannels()
    }
}
