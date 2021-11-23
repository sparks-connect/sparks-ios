//
//  LocalStore.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 25.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

class LocalStore {
    
    private static let kFirstLaunchTime = "firstLaunchTime"
    private static let kLastChannelSeenTime = "lastChannelSeenTime"
    
    static func markFirstLaunch() {
        let v = UserDefaults.standard.value(forKey: kFirstLaunchTime) as? Int64
        if v == nil || v == 0 {
            UserDefaults.standard.setValue(Date().milliseconds, forKey: kFirstLaunchTime)
        }
    }
    
    static var firstLaunchTime: Int64 {
        return UserDefaults.standard.value(forKey: kFirstLaunchTime) as? Int64 ?? 0
    }
    
    static func markChannelsSeen(_ time: Int64) {
        UserDefaults.standard.setValue(time, forKey: kLastChannelSeenTime)
    }
    
    static var lastRecievedChannelRequestTime: Int64 {
        return UserDefaults.standard.value(forKey: kLastChannelSeenTime) as? Int64 ?? 0
    }
}
