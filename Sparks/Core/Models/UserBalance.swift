//
//  UserBalance.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 22.04.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import RealmSwift

class UserBalance: BaseModelObject {
    
    static let kPath = "user-balance"
    
    enum CodingKeys: String, CodingKey {
        case date,
             freeBalance,
             referBalance
    }
    
    /// First name
    @objc dynamic private(set) var date: String?
    /// Last (Family) name
    @objc dynamic private(set) var freeBalance: Int = 0
    /// User email
    @objc dynamic private(set) var referBalance: Int = 0
    
    required override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
        self.freeBalance = try container.decodeIfPresent(Int.self, forKey: .freeBalance) ?? 0
        self.referBalance = try container.decodeIfPresent(Int.self, forKey: .referBalance) ?? 0
    }
}
