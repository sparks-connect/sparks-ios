//
//  UserPhoto.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 03.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

class UserPhoto: BaseModelObject {
    
    enum CodingKeys: String, CodingKey {
        case url,
             createdAt,
             main
    }
    
    @objc dynamic var main: Bool = false
    @objc dynamic private(set) var url: String?
    @objc dynamic private(set) var createdAt: Int64 = 0
    
    override init() {
        super.init()
    }
    
    init(uid: String, url: String, createdAt: Int64, main: Bool) {
        super.init()
        self.uid = uid
        self.url = url
        self.main = main
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.createdAt = try container.decodeIfPresent(Int64.self, forKey: .createdAt) ?? 0
        self.main = try container.decodeIfPresent(Bool.self, forKey: .main) ?? false
    }
    
    func update(photo: UserPhoto) {
        try? self.realm?.write {
            self.url = photo.url
            self.createdAt = photo.createdAt
            self.main = photo.main
        }
    }
}
