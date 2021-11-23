//
//  MemoryStore.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 10/3/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import Foundation

class MemoryStore {
    
    struct MemoryKeys {
        static let userUid = "userUid"
    }
    
    static let sharedInstance = MemoryStore()
    
    private init() {}
    
    private lazy var store = [String : Any]()
    
    func putValue(_ value: Any, forKey key: String) {
        self.store[key] = value
    }
    
    func getValue(forKey key: String) -> Any? {
        return self.store[key]
    }
    
    func removeValue(forKey key: String) {
        self.store.removeValue(forKey: key)
    }
    
    func clear() {
        self.store.removeAll()
    }
}
