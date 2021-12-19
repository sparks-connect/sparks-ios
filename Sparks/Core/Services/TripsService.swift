//
//  TripsService.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

protocol TripsService {
    func fetch(startDate: Double?, randomQueryInt: Int?, limit: Int, completion:@escaping(Result<TripPaginatedResponse, Error>)->Void)
    func create(city: String,
                lat: Double,
                lng: Double,
                purpose: PurposeEnum,
                startDate: Int64,
                endDate: Int64,
                community: TripCommunityEnum,
                plan: String?,
                completion:@escaping(Result<String, Error>)->Void)
    func removeFromFavourites(uid: String, completion:@escaping(Result<Any, Error>)->Void)
}

class TripsServiceImpl: TripsService {
    
    private let firebase: FirebaseAPI
    
    init(firebase: FirebaseAPI = API.firebase) {
        self.firebase = firebase
    }
    
    // https://cloud.google.com/firestore/docs/query-data/query-cursors
    func fetch(startDate: Double?, randomQueryInt: Int?, limit: Int, completion:@escaping(Result<TripPaginatedResponse, Error>)->Void) {
    
        let criteria = TripCriteria.predicates(startDate: startDate, randomQueryInt: randomQueryInt)
        let orderBy = startDate != nil ? [Trip.CodingKeys.startDate.rawValue] : [Trip.CodingKeys.randomQueryInt.rawValue]
        firebase.fetchItems(type: Trip.self,
                            at: Trip.kPath,
                            predicates: criteria,
                            orderBy: orderBy,
                            desc: true,
                            limit: limit) { response in
            
            switch response {
            case .success(let trips):
                
                let max = trips.max { t1, t2 in
                    return t1.startDate > t2.startDate
                }
                
                var next = max?.startDate ?? 0
                if let rand = randomQueryInt {
                    next = Int64(rand)
                }
                
                completion(.success(TripPaginatedResponse(nextStartDate: next, trips: trips)))
                break
                
            case .failure(let e):
                completion(.failure(e))
                break
            }
        }
    }
    
    func create(city: String,
                lat: Double,
                lng: Double,
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
            Trip.CodingKeys.lat.rawValue: lat,
            Trip.CodingKeys.lng.rawValue: lng,
            Trip.CodingKeys.startDate.rawValue: startDate,
            Trip.CodingKeys.endDate.rawValue: endDate,
            Trip.CodingKeys.purpose.rawValue: purpose.rawValue,
            Trip.CodingKeys.community.rawValue: community.rawValue,
            Trip.CodingKeys.userId.rawValue: u.uid,
            Trip.CodingKeys.user.rawValue: u.values,
            Trip.CodingKeys.randomQueryInt.rawValue: Int.random(in: 1...1000000)
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
    
    func update(uid: String,
                city: String,
                lat: Double,
                lng: Double,
                purpose: PurposeEnum,
                startDate: Int64,
                endDate: Int64,
                community: TripCommunityEnum,
                plan: String?,
                completion:@escaping(Result<String, Error>)->Void) {

        var object: [String: Any] = [
            Trip.CodingKeys.city.rawValue: city,
            Trip.CodingKeys.lat.rawValue: lat,
            Trip.CodingKeys.lng.rawValue: lng,
            Trip.CodingKeys.startDate.rawValue: startDate,
            Trip.CodingKeys.endDate.rawValue: endDate,
            Trip.CodingKeys.purpose.rawValue: purpose.rawValue,
            Trip.CodingKeys.community.rawValue: community.rawValue,
         ]
        
        if let plan = plan {
            object[Trip.CodingKeys.plan.rawValue] = plan
        }
        
        firebase.setNode(path: "\(Trip.kPath)/\(uid)", values: object, mergeFields: nil) { result in
            switch result {
            case .success(_):
                completion(.success(uid))
                break
            case .failure(let e):
                completion(.failure(e))
                break
            }
        }
    }
    
    func delete(uid: String,
                completion:@escaping(Result<String, Error>)->Void) {
        firebase.deleteNode(path: "\(Trip.kPath)/\(uid)") { result in
            switch result {
            case .success(_):
                completion(.success(uid))
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
