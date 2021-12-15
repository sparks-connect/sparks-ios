//
//  Trip.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

enum PurposeEnum: Int {
    case leisure = 1
    case business = 2
}

enum TripCommunityEnum: Int {
    case alone = 1
    case friends = 2
    case partner = 3
    case family = 4
    case tourists = 5
}

class Trip: BaseModelObject {
    
    static let kPath = "trips"
    
    enum CodingKeys: String, CodingKey {
        case city,
             startDate,
             endDate,
             purpose,
             community,
             plan,
             user,
             userId
    }
    
    @objc dynamic private(set) var userId: String?
    @objc dynamic private(set) var city: String?
    @objc dynamic private(set) var purpose: Int = PurposeEnum.leisure.rawValue
    @objc dynamic private(set) var startDate: Int64 = 0
    @objc dynamic private(set) var endDate: Int64 = 0
    @objc dynamic private(set) var community: Int = TripCommunityEnum.alone.rawValue
    @objc dynamic private(set) var plan: String?
    @objc dynamic private(set) var user: User?
    
    override init() {
        super.init()
    }
    
    
    init(uid: String,
         userId: String,
         city: String,
         purpose: PurposeEnum,
         startDate: Int64,
         endDate: Int64,
         community: TripCommunityEnum,
         plan: String?,
         user: User) {
        super.init()
        self.uid = uid
        self.city = city
        self.startDate = startDate
        self.endDate = endDate
        self.purpose = purpose.rawValue
        self.community = community.rawValue
        self.plan = plan
        self.userId = userId
        self.user = user
    }
    
    required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.startDate = try container.decodeIfPresent(Int64.self, forKey: .startDate) ?? 0
        self.endDate = try container.decodeIfPresent(Int64.self, forKey: .endDate) ?? 0
        self.purpose = try container.decodeIfPresent(Int.self, forKey: .purpose) ?? PurposeEnum.leisure.rawValue
        self.community = try container.decodeIfPresent(Int.self, forKey: .community) ?? TripCommunityEnum.alone.rawValue
        self.plan = try container.decodeIfPresent(String.self, forKey: .plan)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.user = try container.decodeIfPresent(User.self, forKey: .user)
    }
    
}
