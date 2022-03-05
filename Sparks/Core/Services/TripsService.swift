//
//  TripsService.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

protocol TripsService {
    func fetch(limit: Int, lastItem: Any?, completion:@escaping(Result<TripPaginatedResponse, Error>)->Void)
    func create(city: String,
                lat: Double,
                lng: Double,
                purpose: PurposeEnum,
                startDate: Int64,
                endDate: Int64,
                community: TripCommunityEnum,
                plan: String?,
                completion:@escaping(Result<String, Error>)->Void)
    func addToFavourites(trip: Trip,
                        completion:@escaping(Result<Any, Error>)->Void)
    func removeFromFavourites(uid: String, completion:@escaping(Result<Any, Error>)->Void)
    func fetchMyTrips(completion:@escaping(Result<[Trip], Error>)->Void)
    func fetchTripsForUser(uid: String, completion:@escaping(Result<[Trip], Error>)->Void)
}

class TripsServiceImpl: TripsService {
    
    private let firebase: FirebaseAPI
    private var myTrips = [Trip]()
    
    init(firebase: FirebaseAPI = API.firebase) {
        self.firebase = firebase
    }
    
    private func invalidateMyTrips() {
        self.myTrips.removeAll()
    }
    
    // https://cloud.google.com/firestore/docs/query-data/query-cursors
    func fetch(limit: Int, lastItem: Any?, completion:@escaping(Result<TripPaginatedResponse, Error>)->Void) {
    
        let criteria = TripCriteria.get
        let predicates = criteria?.predicates() ?? TripCriteria.empty()
        
        firebase.fetchItems(type: Trip.self,
                            at: Trip.kPath,
                            predicates: predicates.predicates,
                            orderBy: predicates.sortKeys,
                            desc: true,
                            limit: limit,
                            startAfter: lastItem) {[weak self] response in
            
            switch response {
            case .success(let trips):
                let result = self?.filterLocallyIfNeeded(criteria: criteria, trips: trips.1) ?? []
                completion(.success(TripPaginatedResponse(lastItem: trips.0, trips: result)))
                break
                
            case .failure(let e):
                completion(.failure(e))
                break
            }
        }
    }
    
    private func filterLocallyIfNeeded(criteria: TripCriteria?, trips: [Trip]) -> [Trip] {
        guard let criteria = criteria else {
            return trips.shuffled()
        }
        
        var result = [Trip]()
        trips.forEach { trip in
            let matchesEndDate = trip.endDate < criteria.endDate
            let matchesCity = criteria.city.isEmpty || trip.city == criteria.city
            let matchesGender = (criteria.gender == Gender.both.rawValue || trip.user?.gender == nil) || trip.user?.gender == criteria.gender
            if (matchesEndDate && matchesCity && matchesGender) {
                result.append(trip)
            }
        }
        return result
    }
    
    // https://cloud.google.com/firestore/docs/query-data/query-cursors
    func fetchMyTrips(completion:@escaping(Result<[Trip], Error>)->Void) {
    
        guard let u = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
    
        if (!myTrips.isEmpty) {
            completion(.success(self.myTrips))
            return
        }
        
        fetchTripsForUser(uid: u.uid) {[weak self] response in
            switch response {
            case .success(let trips):
                self?.myTrips = trips
                completion(.success(trips))
                break
            case .failure(let e):
                completion(.failure(e))
                break
            }
        }
    }
    
    // https://cloud.google.com/firestore/docs/query-data/query-cursors
    func fetchTripsForUser(uid: String, completion:@escaping(Result<[Trip], Error>)->Void) {
        
        firebase.fetchItems(type: Trip.self, at: Trip.kPath, predicates: [(Trip.CodingKeys.userId.rawValue, CompareType.equals, uid)]) { response in
            switch response {
            case .success(let trips):
                completion(.success(trips.1))
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
        
        firebase.addNode(path: Trip.kPath, values: object) {[weak self] result in
            switch result {
            case .success(let id):
                completion(.success(id ?? ""))
                self?.invalidateMyTrips()
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
        
        firebase.setNode(path: "\(Trip.kPath)/\(uid)", values: object, mergeFields: nil) {[weak self] result in
            switch result {
            case .success(_):
                completion(.success(uid))
                self?.invalidateMyTrips()
                break
            case .failure(let e):
                completion(.failure(e))
                break
            }
        }
    }
    
    func delete(uid: String,
                completion:@escaping(Result<String, Error>)->Void) {
        firebase.deleteNode(path: "\(Trip.kPath)/\(uid)") {[weak self] result in
            switch result {
            case .success(_):
                completion(.success(uid))
                self?.invalidateMyTrips()
                break
            case .failure(let e):
                completion(.failure(e))
                break
            }
        }
    }
    
    func addToFavourites(trip: Trip,
                        completion:@escaping(Result<Any, Error>)->Void) {
        
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        var favs = [[String: Any]]()
        user.favourites.forEach { item in
            favs.append(item.values)
        }
        
        favs.append(trip.values)
        
        self.firebase.updateNode(path: user.path, values: [User.CodingKeys._favourites.rawValue: favs], completion: { result in
            switch result {
            case .success(_):
                completion(.success(trip.uid))
                break
            case .failure(let e):
                completion(.failure(e))
                break
            }
        })
    }
    
    func removeFromFavourites(uid: String,
                             completion:@escaping(Result<Any, Error>)->Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        var favs = [[String: Any]]()
        user.favourites.forEach { item in
            if item.uid != uid {
                favs.append(item.values)
            }
        }
        
        self.firebase.updateNode(path: user.path, values: [User.CodingKeys._favourites.rawValue: favs], completion: { result in
            switch result {
            case .success(_):
                completion(.success(uid))
                break
            case .failure(let e):
                completion(.failure(e))
                break
            }
        })
    }
}
