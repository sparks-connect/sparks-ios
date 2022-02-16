//
//  DeepLinkHelper.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 10/3/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import Foundation
import FirebaseDynamicLinks

extension URL {
    func getQueryParameterValue(param: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}

class DeepLinkHelper {
    
    struct Constants {
        static let domain = "https://sparks.ooo/links"
    }
    
    static func generateLink(params: [String : String], completion:@escaping (Result<String, Error>)->Void) {
        
        var url = Constants.domain
        var first = true
        params.forEach { (key, val) in
            url.append("\(first ? "?" : "&")\(key)=\(val)")
            first = false
        }
        
        self.generateLink(fullURL: url, completion: completion)
    }
    
    static func generateLink(userUid: String, completion:@escaping (Result<String, Error>)->Void) {
        self.generateLink(fullURL: "\(Constants.domain)/\(userUid)", completion: completion)
    }
    
    private static func generateLink(fullURL: String, completion:@escaping (Result<String, Error>)->Void) {
        
        guard let link = URL(string: fullURL), let bundleId = Consts.App.bundleIdentifier else {
            completion(.failure(CIError.invalidContent))
            return
        }
        
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: Constants.domain)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: bundleId)
        
        linkBuilder?.shorten() { url, warnings, error in
            
            if let e = error {
                completion(.failure(e))
            } else if let url = url {
                completion(.success(url.absoluteString))
            } else {
                completion(.failure(CIError.unknown))
            }
        }
    }
}
