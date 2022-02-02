//
//  ServiceProvider.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/10/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import RealmSwift
import GooglePlaces

class API {

    private static let instance = API()

    private var firebase   : FirebaseAPI!
    private var http       : HttpAPI!
    private var chat       : ChatAPI!
    private var storage    : IStorageAPI!
    
    private init() {}

    class func setup() {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        GMSPlacesClient.provideAPIKey("AIzaSyDgFqRIsnj22oMHuOCenbqhJ7LaTDAC9vg")
        FirebaseAPIImpl.setup()
        instance.firebase = FirebaseAPIImpl()
        instance.http = HttpAPIImpl()
        instance.chat = ChatAPIImpl(user: User.current)
        instance.storage = StorageAPIImpl()
    }

    class var http: HttpAPI {
        return self.instance.http
    }

    class var firebase: FirebaseAPI {
        return self.instance.firebase
    }

    class var chat: ChatAPI {
        return self.instance.chat
    }
    
    class var storage: IStorageAPI {
        return self.instance.storage
    }
}
