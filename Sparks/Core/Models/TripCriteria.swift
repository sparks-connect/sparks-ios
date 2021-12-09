//
//  TripCriteria.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

class TripCriteria: BaseModelObject {
    @objc dynamic private(set) var city: String?
    @objc dynamic private(set) var startDate: Int64 = 0
    @objc dynamic private(set) var endDate: Int64 = 2524593600000000
    @objc dynamic private(set) var ageFrom: Int64 = 18
    @objc dynamic private(set) var geTo: Int64 = 90
    @objc dynamic private(set) var gender: String = Gender.both.rawValue
    
    class func defaultCriteria() -> TripCriteria {
        let object = TripCriteria()
        object.uid = UUID().uuidString
        return object
    }
    
    class func predicates() -> [Predicate] {
        let criteria = RealmUtils.fetch(TripCriteria.self).first ?? defaultCriteria()
        var predicate: [Predicate] = []

        if let city = criteria.city {
            predicate.append((Trip.CodingKeys.city.rawValue, .equals, city))
        }
        
        predicate.append((Trip.CodingKeys.startDate.rawValue, .greaterThanOrEqual, criteria.startDate))
        
        return predicate
    }
}
