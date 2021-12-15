//
//  TripsService.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

protocol TripsService {
    func fetch(completion:@escaping(Result<[Trip], Error>)->Void)
    func create(city: String,
                purpose: PurposeEnum,
                startDate: Int64,
                endDate: Int64,
                community: TripCommunityEnum,
                plan: String?,
                completion:@escaping(Result<String, Error>)->Void)
    func addToFavourites(uid: String, completion:@escaping(Result<Any, Error>)->Void)
    func removeFromFavourites(uid: String, completion:@escaping(Result<Any, Error>)->Void)
}

class TripsServiceImpl: TripsService {
    
    private let firebase: FirebaseAPI
    
    init(firebase: FirebaseAPI = API.firebase) {
        self.firebase = firebase
    }
    
    func fetch(completion:@escaping(Result<[Trip], Error>)->Void) {
    
        //TODO: We need to implement paging using ↓
        // https://cloud.google.com/firestore/docs/query-data/query-cursors
        // We should fetch 1 month batch for a single query
        
        firebase.fetchItems(type: Trip.self, at: Trip.kPath, predicates: TripCriteria.predicates(), completion: completion)
    }
    
    func create(city: String,
                purpose: PurposeEnum,
                startDate: Int64,
                endDate: Int64,
                community: TripCommunityEnum,
                plan: String?,
                completion:@escaping(Result<String, Error>)->Void) {
     
        guard let u = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        var object: [String: Any] = [
            Trip.CodingKeys.city.rawValue: city,
            Trip.CodingKeys.startDate.rawValue: startDate,
            Trip.CodingKeys.endDate.rawValue: endDate,
            Trip.CodingKeys.purpose.rawValue: purpose.rawValue,
            Trip.CodingKeys.community.rawValue: community.rawValue,
            Trip.CodingKeys.userId.rawValue: u.uid,
            Trip.CodingKeys.user.rawValue: u.values
         ]
        
        if let plan = plan {
            object[Trip.CodingKeys.plan.rawValue] = plan
        }
        
        firebase.addNode(path: Trip.kPath, values: object) { result in
            switch result {
            case .success(let id):
                completion(.success(id ?? ""))
                break
            case .failure(let e):
                completion(.failure(e))
                break
            }
        }
    }
    
    func addToFavourites(uid: String,
                        completion:@escaping(Result<Any, Error>)->Void) {
        
    }
    
    func removeFromFavourites(uid: String,
                             completion:@escaping(Result<Any, Error>)->Void) {
        
    }
}
