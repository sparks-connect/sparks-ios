//
//  FirebaseConfigManager.swift
//  Sparks
//
//  Created by George Vashakidze on 3/25/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

class FirebaseConfigManager {

    static let shared = FirebaseConfigManager()

    internal enum Key: String {
        case maxAgePref
        case minAgePref
        case distancePref
        case genderPref
        case termsAndConditionsUrl
        case settings
        case countries
        case maxCharacterCount
    }

    private let remoteConfig: RemoteConfig

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()

        #if RELEASE
        let plistName = "RemoteConfigDefaults-Prod"
        #elseif STAGING
        let plistName = "RemoteConfigDefaults-Staging"
        #else
        let plistName = "RemoteConfigDefaults-Dev"
        #endif

        remoteConfig.setDefaults(fromPlist: plistName)
    }

    func refetch(_ completion: @escaping (Bool) -> Void) {
        self.remoteConfig.activate { ok, error in
            if let error = error {
                completion(false)
                print(error)
            }
        }
        
        remoteConfig.fetch(withExpirationDuration: 0) { [unowned self] status, error in
            switch status {
            case .noFetchYet:
                completion(false)
                print("Finished RemoteConfig fetch with status noFetchYet")
                break
            case .failure:
                completion(false)
                print("Finished RemoteConfig fetch with status failure")
                break
            case .throttled:
                completion(false)
                print("Finished RemoteConfig fetch with status throttled")
                break
            case .success:
                self.remoteConfig.activate(completion: nil)
                completion(true)
            @unknown default:
                completion(false)
                print("Unhandled case when fetching remote configs, status: \(status.rawValue)")
                break
            }
            print(error)
        }
    }
  
    var maxAgePref: Int {
        return remoteConfig.number(forKey: .maxAgePref)?.intValue ?? 32
    }
    
    var minAgePref: Int {
        return remoteConfig.number(forKey: .minAgePref)?.intValue ?? 18
    }
    
    var distancePref: Int {
        return remoteConfig.number(forKey: .distancePref)?.intValue ?? 10
    }
    
    var genderPref: String {
        return remoteConfig.string(forKey: .genderPref) ?? Gender.both.rawValue
    }
    
    var settings: [SettingsItem] {
        return remoteConfig.decodable(forKey: .settings) ?? [SettingsItem]()
    }
    
    var countries: [Country] {
        return remoteConfig.decodable(forKey: .countries) ?? [Country]()
    }
    
    var maxCharacterCount: Int {
        return remoteConfig.number(forKey: .maxCharacterCount)?.intValue ?? 250
    }
    
}

extension RemoteConfig {

    func configValue(forKey key: FirebaseConfigManager.Key) -> RemoteConfigValue? {
        let value = configValue(forKey: key.rawValue)
        return (value.source != .static) ? value : nil
    }

    func bool(forKey key: FirebaseConfigManager.Key) -> Bool? {
        return configValue(forKey: key)?.boolValue
    }

    func decodable<T: Decodable>(forKey key: FirebaseConfigManager.Key) -> T? {
        guard let data = configValue(forKey: key)?.dataValue else { return nil }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            return try decoder.decode(T.self, from: data)
        } catch let error {
            print(error)
            return nil
        }
    }

    func number(forKey key: FirebaseConfigManager.Key) -> NSNumber? {
        return configValue(forKey: key)?.numberValue
    }

    func string(forKey key: FirebaseConfigManager.Key) -> String? {
        return configValue(forKey: key)?.stringValue
    }

}
