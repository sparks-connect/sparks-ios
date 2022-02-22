//
//  TagsService.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 27.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

protocol TagsService {
    func fetchTags()
    func tag(forKey: String) -> ProfileTag?
}

class TagsServiceImpl: TagsService {
    
    private let firebase: FirebaseAPI
    private lazy var dataSource: [String: ProfileTag] = [:]
    
    init(firebase: FirebaseAPI = API.firebase) {
        self.firebase = firebase
        NotificationCenter.default.addObserver(forName: Notification.Name("logout"), object: nil, queue: .main) { _ in
            self.dataSource.removeAll()
            self.fetchTags()
        }
    }
    
    private func isEmpty() -> Bool {
        self.dataSource.isEmpty
    }
    
    func tag(forKey: String) -> ProfileTag? {
        
        if self.isEmpty() {
            self.fetchTagsLocal()
        }
        
        return self.dataSource[forKey]
    }
    
    private func fetchTagsLocal() {
        let results = RealmUtils.fetch(ProfileTag.self)
        results.forEach { tag in
            self.dataSource[tag.uid] = tag
        }
    }
    
    func fetchTags() {
    
        firebase.fetchItems(type: ProfileTag.self, at: ProfileTag.kPath, predicates: []) { response in
            switch response {
            case .success(let res):
                self.dataSource.removeAll()
                RealmUtils.fetch(ProfileTag.self).forEach { tag in
                    RealmUtils.delete(object: tag)
                }
                res.1.forEach { tag in
                    RealmUtils.save(object: tag)
                }
                
                if self.isEmpty() {
                    self.fetchTagsLocal()
                }
                
                break
            case .failure(let error):
                debugPrint(error)
                break
            }
        }
    }
}
