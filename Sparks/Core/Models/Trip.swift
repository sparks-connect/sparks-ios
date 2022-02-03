//
//  Trip.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

protocol Tag: CaseIterable, RawRepresentable {
    func getLabel() -> String
}

enum PurposeEnum: Int, Tag {
    case leisure = 1
    case business = 2
    
    func getLabel() -> String {
        switch self {
        case .leisure:
           return "Leisure"
        case .business:
           return "Business"
        }
    }
}

enum TripCommunityEnum: Int, Tag {
    case alone = 1
    case friends = 2
    case partner = 3
    case family = 4
    case tourists = 5
    
    func getLabel() -> String {
        switch self {
        case .alone:
            return "alone"
        case .friends:
            return "with friends"
        case .partner:
            return "with partner"
        case .family:
            return "with family"
        case .tourists:
            return "with group of tourists"
        }
    }
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
             userId,
             lat,
             lng,
             randomQueryInt
    }
    
    @objc dynamic private(set) var userId: String?
    @objc dynamic private(set) var city: String?
    @objc dynamic private(set) var purpose: Int = PurposeEnum.leisure.rawValue
    @objc dynamic private(set) var startDate: Int64 = 0
    @objc dynamic private(set) var endDate: Int64 = 0
    @objc dynamic private(set) var community: Int = TripCommunityEnum.alone.rawValue
    @objc dynamic private(set) var plan: String?
    @objc dynamic private(set) var user: User?
    @objc dynamic private(set) var lat: Double = 0
    @objc dynamic private(set) var lng: Double = 0
    @objc dynamic private(set) var randomQueryInt: Int = 0
    
    override init() {
        super.init()
    }
    
    
    init(uid: String,
         userId: String,
         city: String,
         lat: Double,
         lng: Double,
         purpose: PurposeEnum,
         startDate: Int64,
         endDate: Int64,
         community: TripCommunityEnum,
         plan: String?,
         randomQueryInt: Int,
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
        self.lat = lat
        self.lng = lng
        self.randomQueryInt = randomQueryInt
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
        self.lat = try container.decodeIfPresent(Double.self, forKey: .lat) ?? 0
        self.lng = try container.decodeIfPresent(Double.self, forKey: .lng) ?? 0
        self.randomQueryInt = try container.decodeIfPresent(Int.self, forKey: .randomQueryInt) ?? 0
    }
    
}
