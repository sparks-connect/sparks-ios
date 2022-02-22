//
//  TripCriteria.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

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
    
    class func create(criteria: TripCriteria){
        RealmUtils.save(object: criteria)
    }
    
    func save(city: String, startDate: Int64 = 0, endDate: Int64 = 0, gender: Gender = .both){
        try? self.realm?.write {
            self.city = city
            self.startDate = startDate
            self.endDate = endDate
            self.gender = gender.rawValue
        }
    }
    
    class var get: TripCriteria? {
        RealmUtils.fetch(TripCriteria.self).first
    }
    
    class func empty() -> (predicates: [Predicate], sortKeys: [String]) {
        return ([], [Trip.CodingKeys.randomQueryInt.rawValue])
    }
    
    func predicates() -> (predicates: [Predicate], sortKeys: [String]) {
        var predicate: [Predicate] = []
        if !city.isEmpty {
            predicate.append((Trip.CodingKeys.city.rawValue, .equals, self.city))
        }
        predicate.append((Trip.CodingKeys.startDate.rawValue, .greaterThanOrEqual, self.startDate))
        return (predicate, [Trip.CodingKeys.startDate.rawValue])
    }
}
