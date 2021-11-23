//
//  ProfileTag.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 22.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

class ProfileTag: BaseModelObject {
    
    static let kPath = "profile-tags"
    enum CodingKeys: String, CodingKey {
        case name,
             order
    }
    
    @objc dynamic var name: String?
    @objc dynamic var order: Int = 0
    
    override init() {
        super.init()
    }
    
    init(uid: String, name: String, order: Int) {
        super.init()
        self.uid = uid
        self.name = name
        self.order = order
    }
    
    required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.order = try container.decodeIfPresent(Int.self, forKey: .order) ?? 0
    }
    
    func update(tag: ProfileTag) {
        try? self.realm?.write {
            self.name = tag.name
            self.order = tag.order
        }
    }
}
