//
//  InstaService.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/01/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import SwiftUI

enum InstaStep {
    case authorize
    case token
    case media
    case album
    case user
    
    func baseURL() -> String {
        let apiBase = Consts.Insta.instaBaseUrl
        let graphBase = Consts.Insta.graphBaseUrl
        
        switch self {
        case .authorize:
            return apiBase + "authorize"
        case .token:
            return apiBase + "access_token"
        case .media:
            return  graphBase + "me/media"
        case .album:
            return  graphBase + "me/media"
        case .user:
            return  graphBase + "me"
        }
    }
    
    func url() -> URL{
        return URL(string: baseURL())!
    }
}
/* 
class InstaProfile: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case username
    }
    var id: String?
    var username: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
    }
}
*/
class InstaInfo: Codable {
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case accessToken = "access_token"
    }
    var userId: Int64?
    var accessToken: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(Int64.self, forKey: .userId)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
    }
}

class InstaLongLivedToken: Codable {
    private enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case timestamp = "expires_in"
    }
    var tokenType: String?
    var accessToken: String?
    var timestamp: Int64?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.timestamp = try container.decode(Int64.self, forKey: .timestamp)
    }
}

class InstaData: Codable{
    var data: [InstaMedia]?
    var paging: Page?
}

class Page: Codable {
    var next: String?
}

enum MediaType: String, Codable {
    case image = "IMAGE"
    case video = "VIDEO"
    case album = "CAROUSEL_ALBUM"
}

class InstaMedia: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case mediaUrl = "media_url"
        case mediaType = "media_type"
    }
    var id: String?
    var mediaUrl: String?
    var mediaType: MediaType?
    var username: String?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.mediaUrl = try container.decode(String.self, forKey: .mediaUrl)
        self.mediaType = try container.decode(MediaType.self, forKey: .mediaType)
    }
}


protocol InstaService {
    func getAuthorizationURL() -> URL
    func getAccessToken(code: String, completion: @escaping (Result<Any?, Error>) -> Void)
    func getMedia(next: String?, completion: @escaping (Result<InstaData?, Error>) -> Void)
    func saveLongLivedToken()
}

class InstaServiceImpl: InstaService {
    
    private let api: HttpAPI
    private let fireBaseApi: FirebaseAPI
    
    init(api: HttpAPI = API.http, firebase: FirebaseAPI = API.firebase) {
        self.api = api
        self.fireBaseApi = firebase
    }
    
    func getAuthorizationURL() -> URL {
        let baseURL = InstaStep.authorize.baseURL() + "?client_id=\(Consts.Insta.clientID)"  + "&redirect_uri=\(Consts.Insta.redirectURI)"
        let scope  =  baseURL + "&scope=user_profile,user_media"
        let authURL  = scope + "&response_type=code"
        return URL(string: authURL)!
    }
    
    func getAccessToken(code: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        let params: [String: Any] = ["client_id": Consts.Insta.clientID,
                                     "client_secret": Consts.Insta.clientSecret,
                                     "grant_type": "authorization_code",
                                     "redirect_uri": Consts.Insta.redirectURI,
                                     "code": code]
        self.api.send(for: InstaStep.token.url(), method: .post, params: params, headers: ["Content-Type": "application/x-www-form-urlencoded"]) { result in
            switch result {
            case .success(let data):
                if let rawData = data {
                    let instaInfo = try? JSONDecoder().decode(InstaInfo.self, from: rawData)
                    guard let user = User.current,let info = instaInfo else {
                        completion(.failure(CIError.unauthorized))
                        return
                    }
                    self.fireBaseApi.updateNode(path: user.path, values: [User.CodingKeys.instaID.rawValue: info.userId ?? 0,
                                                                          User.CodingKeys.instaToken.rawValue: info.accessToken ?? ""], completion: completion)
                    self.saveLongLivedToken()
                }else {
                    completion(.failure(CIError.unknown))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getMedia(next: String?, completion: @escaping (Result<InstaData?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        let params: [String: Any] = ["access_token": user.instaToken ?? "",
                                     "limit": 10,
                                     "fields": "id,username,caption,media_url,media_type,thumbnail_url"]
        // For Paging....
        // Use next as url
        let base = InstaStep.media.url()
        self.api.send(for: next != nil ? URL(string: next ?? "") ?? base : base,
                     method: .get,
                     params: next != nil ? nil : params,
                     headers: nil) { result in
            switch result {
            case .success(let data):
                if let rawData = data {
                    let instaData = try? JSONDecoder().decode(InstaData.self, from: rawData)
                    guard let user = User.current,let info = instaData else {
                        return
                    }
                    if let data = info.data, data.count > 0 {
                        self.fireBaseApi.updateNode(path: user.path, values: [
                            User.CodingKeys.instaUserName.rawValue: "@\(data[0].username ?? "")" ], completion: nil)
                    }
                    completion(.success(instaData))
                }else {
                    completion(.failure(CIError.unknown))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func saveLongLivedToken() {
        let params: [String: Any] = ["client_id": Consts.Insta.clientID,
                                     "client_secret": Consts.Insta.clientSecret,
                                     "grant_type": "ig_exchange_token"]
        
        self.api.send(for: InstaStep.token.url(), method: .get, params: params, headers: ["Content-Type": "application/x-www-form-urlencoded"]) { result in
            switch result {
            case .success(let data):
                if let rawData = data {
                    let instaInfo = try? JSONDecoder().decode(InstaLongLivedToken.self, from: rawData)
                    guard let user = User.current,let info = instaInfo else {
                        return
                    }
                    self.fireBaseApi.updateNode(path: user.path, values: [
                         User.CodingKeys.instaToken.rawValue: info.accessToken ?? ""], completion: nil)
                }
            case .failure(_): break
            }
        }
    }
    /*
    func getUserName(){
        guard let user = User.current else {
            return
        }
        let params: [String: Any] = ["access_token": user.instaToken ?? "",
                                     "fields": "id,username"]
        
        self.api.send(for: InstaStep.user.url(),
                         method: .get,
                         params: params,
                         headers: nil) { result in
            switch result {
            case .success(let data):
                if let rawData = data {
                    let instaData = try? JSONDecoder().decode(InstaProfile.self, from: rawData)
                    guard let user = User.current,let info = instaData else {
                        return
                    }
                    self.fireBaseApi.updateNode(path: user.path, values: [
                        User.CodingKeys.instaUserName.rawValue: info.username ?? ""], completion: nil)
                    
                }
            case .failure(_):
                break
            }
        }
    }
     */
    
}
