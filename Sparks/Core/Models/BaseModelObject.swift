//
//  BaseModelObject.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 6/4/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import RealmSwift

class BaseModelObject: Object, Codable {
    @objc dynamic var uid = ""
    
    // MARK: Realm
    
    override class func primaryKey() -> String {
        return BaseCodingKeys.uid.rawValue
    }
    
    enum BaseCodingKeys: String, CodingKey {
        case uid
    }
}
