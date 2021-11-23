//
//  Realm.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 4/22/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import RealmSwift

class RealmUtils {
    
    class func configure() {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    }
    
    class func save(object: Object) {
        let realm = try? Realm()
        try? realm?.write {
            realm?.add(object, update: .modified)
        }
    }
    
    class func delete(object: Object) {
        let realm = try? Realm()
        try? realm?.write {
            realm?.delete(object)
        }
        
    }
    
    class func save(objects: [Object]) {
        let realm = try? Realm()
        try? realm?.write {
            realm?.add(objects, update: .modified)
        }
    }
    
    class func fetch<T: Object>(predicate: @escaping(_ a: T) ->Bool) -> [T] {
        let realm = try? Realm()
        realm?.refresh()
        if let results = realm?.objects(T.self).filter(predicate) {
            return Array(results)
        }
        return []
    }
    
    class func fetch<T: Object>(_ type: T.Type, nsPredicate: NSPredicate) -> [T] {
        let realm = try? Realm()
        realm?.refresh()
        if let results = realm?.objects(type).filter(nsPredicate) {
            return Array(results)
        }
        return []
    }
    
    class func fetch<T: Object>(_ type: T.Type) -> [T] {
       let realm = try? Realm()
       realm?.refresh()
       if let results = realm?.objects(T.self) {
           return Array(results)
       }
       return []
    }
    
    class func first<T: Object>(type: T.Type, _ key: String) -> T? {
        let realm = try? Realm()
        realm?.refresh()
        return realm?.object(ofType: T.self, forPrimaryKey: key)
    }
    
    class func observe<T: Object>(predicate: NSPredicate? = nil,
                                  sortedByKeyPath keyPath: String? = nil,
                                  ascending: Bool = true,
                                  change:@escaping(RealmCollectionChange<Results<T>>)->Void) -> NotificationToken? {
        let realm = try? Realm()
        _ = realm?.refresh()
        var result = realm?.objects(T.self)
        if let pred = predicate {
            result = result?.filter(pred)
        }
        
        if let keyPath = keyPath {
            result = result?.sorted(byKeyPath: keyPath, ascending: ascending)
        }

        return result?.observe(change)
    }
    
    class func observe<T: Object>(uid: String,
                                  change:@escaping(ObjectChange<T>)->Void) -> NotificationToken? {
        let realm = try? Realm()
        _ = realm?.refresh()
        let result = realm?.object(ofType: T.self, forPrimaryKey: uid)
        return result?.observe(change)
    }
    
    @discardableResult class func observeUserUpdates(completion:@escaping()->Void) -> NotificationToken? {
        return observe { (change: RealmCollectionChange<Results<User>>) in
            completion()
        }
    }
    
    @discardableResult class func observeChannelUpdates(completion:@escaping()->Void) -> NotificationToken? {
        return observe { (change: RealmCollectionChange<Results<Channel>>) in
                  completion()
            }
    }
    
    class func observeChannelRequests(completion:@escaping(Array<Channel>, [Int]?, [Int]?, [Int]?)->Void) -> NotificationToken? {
        return observe(predicate: Channel.recievedRequestsPredicate, sortedByKeyPath: "createdAt", ascending: false) { (change: RealmCollectionChange<Results<Channel>>) in
            switch change {
            case .initial(let result):
                completion(Array(result), nil, nil, nil)
                break
            case .update(let result, let deletions, let insertions, let modifications):
                completion(Array(result), deletions, insertions, modifications)
                break
            default: break
            }
        }
    }
    
    class func deleteAll() {
        let realm = try? Realm()
        realm?.refresh()
        
        try? realm?.write {
            realm?.deleteAll()
            realm?.refresh()
        }
    }
}

// This extension is because Realm sends notifications on updates unnecessarily. https://github.com/realm/realm-core/issues/2787

extension List where Element: BaseModelObject {
    
    func update(withArray array: [Element]?) {
        guard let array = array, array.count > 0 else {
            self.removeAll()
            return
        }
        
        let newSet = Set(array)
        let existingSet = Set(self)
        
        let deletions = existingSet.subtracting(newSet)
        let additions = newSet.subtracting(existingSet)
        
        for deletion in deletions {
            if let index = self.index(of: deletion) {
                self.remove(at: index)
            }
        }
        
        // They need to be ordered by index in order to insert them without skipping indexes causing insert exceptions.
        let additionArray = Array(additions).sorted { array.firstIndex(of: $0)! < array.firstIndex(of: $1)! }
        for addition in additionArray {
            if let index = array.firstIndex(of: addition) {
                self.insert(addition, at: index)
            }
        }
    }
    
}
