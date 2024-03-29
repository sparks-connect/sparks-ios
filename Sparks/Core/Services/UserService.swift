//
//  Auth.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/13/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase

protocol UserService {

    /// Phone verification
    func verifyPhoneNumber(_ phoneNumber: String, completion:@escaping(_ response: Result<String, Error>) -> Void)
    
    /// Phone sign in
    func signIn(verificationID: String, verificationCode: String, completion:@escaping(_ response: Result<Any?, Error>) -> Void)
    
    /// Facebook Authentication
    func fbAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void)

    /// Facebook Authentication
    func appleAuth(credential: AuthCredential, completion: @escaping (Result<Any?, Error>) -> Void)
    
    /// Google authentication
    func googleAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void)
    
    /// Log out
    func logout()

    /// Update Gender
    func updateGender(_ gender: Gender, completion: @escaping (Result<Any?, Error>) -> Void)
        
    /// Update birthdate
    func updateBirthDate(_ birthDate: Int64, completion: @escaping (Result<Any?, Error>) -> Void)
    
    /// Update firstname
    func updateFirstname(_ firstname: String, completion: @escaping (Result<Any?, Error>) -> Void)
   
    /// Update profile
    func updatePreferences(gender: Gender,
                           minAge: Int,
                           maxAge: Int,
                           distance: Int,
                           completion: @escaping (Result<Any?, Error>) -> Void)

    func updateToken(_ token: String, completion: @escaping (Result<Any?, Error>) -> Void)
    
    func addOrRemoveInterest(_ interest: String, completion: @escaping (Result<Any?, Error>) -> Void)
    
    /// GPS
    func requestGPSAuthorization()
    func startGPSTracking()
    func stopGPSTracking()
    func restartGPSTracking(interval: TimeInterval)
    func startSignificantGPSMonitoring()
    
    func deletePhoto(photo: UserPhoto,
                     completion: @escaping (Result<Any?, Error>) -> Void)
    
    func uploadPhotos(urls: [(url: URL, main: Bool)],
                      completion: @escaping (Result<Any?, Error>) -> Void)
}

class UserServiceImpl: UserService {
    
    let api: FirebaseAPI
    init(api: FirebaseAPI = API.firebase) {
        self.api = api
        LocationManager.sharedInstance.delegate = self
    }

    func fbAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void) {
        api.fbAuth(controller: controller, completion: completion)
    }
    
    func appleAuth(credential: AuthCredential, completion: @escaping (Result<Any?, Error>) -> Void) {
        api.appleAuth(credential: credential, completion: completion)
    }

    func googleAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void) {
        api.googleAuth(controller: controller, completion: completion)
    }
    
    func logout() {
        api.logOut()
    }

    func updateGender(_ gender: Gender, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        api.updateNode(path: user.path, values: [User.CodingKeys.gender.rawValue: gender.rawValue], completion: completion)
    }
    
    func updateBirthDate(_ birthDate: Int64, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        api.updateNode(path: user.path, values: [User.CodingKeys.birthDate.rawValue: birthDate], completion: completion)
    }
    
    func updateFirstname(_ firstname: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        api.updateNode(path: user.path, values: [User.CodingKeys.firstName.rawValue: firstname], completion: completion)
    }
    
    func updateToken(_ token: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        api.updateToken(token, completion: completion)
    }
   
    func updatePreferences(gender: Gender,
                            minAge: Int,
                            maxAge: Int,
                            distance: Int,
                            completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        let values: [String: Any] = [
            User.CodingKeys.genderPreference.rawValue: gender.rawValue,
            User.CodingKeys.minAge.rawValue: minAge,
            User.CodingKeys.maxAge.rawValue: maxAge,
            User.CodingKeys.distance.rawValue: distance
        ]
        
        api.updateNode(path: user.path, values: values, completion: completion)
    }
    
    func uploadPhotos(urls: [(url: URL, main: Bool)],
                      completion: @escaping (Result<Any?, Error>) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue.global()
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        var photos = [[String: Any]]()
        let path = user.path
        var newUrls = [(url: String, main: Bool)]()
        let userId = user.uid
        
        let isMainPhotoUpload = urls.count == 1 && urls.first?.main == true
        
        var userPhotos = Array(user.photos)
        if (isMainPhotoUpload) {
            userPhotos = Array(userPhotos.filter({ $0.main == false }))
        }
        
        for photo in userPhotos {
            photos.append(photo.values)
        }
        
        urls.forEach { url in
                
            dispatchGroup.enter()
            dispatchQueue.async {
                if let data = try? Data(contentsOf: url.url) {
                    
                    API.storage.uploadFile(to: "users/\(userId)/profileimage\(UUID().uuidString).jpg",
                                           file: data,
                                           contentType: "image/jpeg",
                                           completion: { (response) in

                        switch response {
                        case .success(let _url):
                            newUrls.append((_url, url.main))
                            break
                        default: break
                        }

                        dispatchQueue.async {
                            dispatchGroup.leave()
                        }
                    }, progressBlock: nil)
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        
        
        dispatchGroup.notify(queue: dispatchQueue) { [weak self] in
            
            for photo in newUrls {
                photos.append([
                    UserPhoto.CodingKeys.url.rawValue: photo.url,
                    UserPhoto.CodingKeys.createdAt.rawValue: Date().timeIntervalAsImpreciseToken,
                    UserPhoto.CodingKeys.main.rawValue: photo.main,
                    BaseModelObject.BaseCodingKeys.uid.rawValue: UUID().uuidString,
                ])
            }
            
            
            self?.api.updateNode(path: "\(path)", values: ["photos": photos], completion: completion)
        }
    }
    
    func deletePhoto(photo: UserPhoto,
                     completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        var photos = [Any]()
        
        user.photos.forEach { _photo in
            
            if(photo.uid != _photo.uid) {
                photos.append([
                    UserPhoto.CodingKeys.url.rawValue: _photo.url ?? "",
                    UserPhoto.CodingKeys.createdAt.rawValue: _photo.createdAt,
                    UserPhoto.CodingKeys.main.rawValue: _photo.main,
                    BaseModelObject.BaseCodingKeys.uid.rawValue: _photo.uid,
                ])
            }
        }
        
        self.api.updateNode(path: "\(user.path)", values: ["photos": photos], completion: completion)
        API.storage.deleteFile(to: "users/\(user.uid)/profileimage\(photo.uid).jpg", completion: nil)
    }
    
    func addOrRemoveInterest(_ interest: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        var tags: [String] = user.profileTags.map({ $0 })
        if (!tags.contains(interest)) {
            tags.append(interest)
        } else {
            if let idx = tags.firstIndex(of: interest) {
                tags.remove(at: idx)
            }
        }
        
        api.updateNode(path: user.path, values: [User.CodingKeys.profileTags.rawValue: tags], completion: completion)
    }
    
    func requestGPSAuthorization() {
        LocationManager.sharedInstance.requestAuthorization()
    }

    func startGPSTracking() {
        LocationManager.sharedInstance.startUpdating()
    }

    func stopGPSTracking() {
        LocationManager.sharedInstance.stopUpdating()
    }

    func restartGPSTracking(interval: TimeInterval) {
        LocationManager.sharedInstance.restart(for: interval)
    }
    
    func startSignificantGPSMonitoring() {
        LocationManager.sharedInstance.startMonitoringSignificantLocationChanges()
    }

    private func updateUserLocation(_ lat: Double, lng: Double) {
        guard let user = User.current else { return }
        api.updateNode(path: user.path, values: [User.CodingKeys.lat.rawValue: lat,
                                                 User.CodingKeys.lng.rawValue: lng], completion: nil)
    }
    
    func signIn(verificationID: String, verificationCode: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        self.api.signIn(verificationID: verificationID, verificationCode: verificationCode, completion: completion)
    }
    
    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.api.verifyPhoneNumber(phoneNumber, completion: completion)
    }
}

extension UserServiceImpl: LocationManagerDelegate {
    func didUpdateTo(_ lat: Double, _ lng: Double) {
        self.updateUserLocation(lat, lng: lng)
    }
}
