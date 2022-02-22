//
//  TripCriteria.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

class TripCriteria: BaseModelObject {
    @objc dynamic private(set) var city: String = ""
    @objc dynamic private(set) var startDate: Int64 = 0
    @objc dynamic private(set) var endDate: Int64 = 2524593600000000
    @objc dynamic private(set) var gender: String = Gender.both.rawValue
    
    override init() {
        super.init()
    }
    
    init(city: String, startDate: Int64 = 0, endDate: Int64 = 0, gender: Gender = .both) {
        super.init()
        self.uid = UUID().uuidString
        self.city = city
        self.startDate = startDate
        self.endDate = endDate
        self.gender = gender.rawValue
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    class func defaultCriteria() -> TripCriteria {
        let object = TripCriteria()
        object.uid = UUID().uuidString
        return object
    }
    
    func update(criteria: TripCriteria){
        RealmUtils.save(object: criteria)
    }
    
    class func predicates(startDate: Int64?) -> (predicates: [Predicate], sortKeys: [String]) {
        
        let orderBy = startDate != nil ? [Trip.CodingKeys.startDate.rawValue] : [Trip.CodingKeys.randomQueryInt.rawValue]
        var predicate: [Predicate] = []
        
        if let startDate = startDate {
            predicate.append((Trip.CodingKeys.startDate.rawValue, .greaterThanOrEqual, startDate))
        } else {
            guard let criteria = RealmUtils.fetch(TripCriteria.self).first else {
                return ([(Trip.CodingKeys.randomQueryInt.rawValue, .greaterThanOrEqual, startDate ?? Int64.random(in: 1...1000000))], orderBy)
            }
            
            predicate.append((Trip.CodingKeys.city.rawValue, .equals, criteria.city))
            predicate.append((Trip.CodingKeys.startDate.rawValue, .greaterThanOrEqual, criteria.startDate))
        }
        
        return (predicate, orderBy)
    }
}
