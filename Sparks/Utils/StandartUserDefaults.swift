//
//  StandartUserDefaults.swift
//  Sparks
//
//  Created by George Vashakidze on 3/25/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

final class StandardUserDefaults {

    enum Key: String {
        case boolKeyHere
        case arrayKeyHere
    }
    
    //TODO: This is for demonstration
    //TODO: Replace with real values
    static var boolKeyHere: Bool {
        get {
            return bool(forKey: .boolKeyHere)
        }
        set {
            set(newValue, forKey: .boolKeyHere)
        }
    }
    
    //TODO: This is for demonstration
    //TODO: Replace with real values
    static var arrayKeyHere: [Int64]? {
        get {
            return decodable(forKey: .arrayKeyHere)
        }
        set {
            setEncodable(newValue, forKey: .arrayKeyHere)
        }
    }    

}

extension StandardUserDefaults {

    private class func bool(forKey key: Key) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    private class func data(forKey key: Key) -> Data? {
        return UserDefaults.standard.data(forKey: key.rawValue)
    }

    private class func dictionary(forKey key: Key) -> [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: key.rawValue)
    }

    private class func double(forKey key: Key) -> Double {
        return UserDefaults.standard.double(forKey: key.rawValue)
    }

    private class func int64(forKey key: Key) -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: key.rawValue))
    }

    private class func integer(forKey key: Key) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }

    private class func string(forKey key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    private class func stringArray(forKey key: Key) -> [String]? {
        return UserDefaults.standard.stringArray(forKey: key.rawValue)
    }

    private class func set(_ value: Any?, forKey key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    private class func decodable<T: Decodable>(forKey key: Key) -> T? {
        guard let data = data(forKey: key) else { return nil }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    private class func setEncodable<T: Encodable>(_ value: T?, forKey key: Key) {
        guard let value = value else {
            set(nil, forKey: key)
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            set(try encoder.encode(value), forKey: key)
        } catch {
            set(nil, forKey: key)
        }
    }

}
