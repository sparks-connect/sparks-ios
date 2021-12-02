//
//  ProfilePresenter.swift
//  Sparks
//
//  Created by Nika Samadashvili on 8/26/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

protocol ProfileDelegate : BasePresenterView {
}
class OldProfilePresenter: BasePresenter< ProfileDelegate > {
    
    private var datasource = [UserProfileItem]()
    private var userPhotosDataSource = [URL]()
    private var tagsDatasource: [String: ProfileTag] = [:]
    
    var numberOfItems: Int {
        return datasource.count
    }
    
    var numberOfPhotos: Int {
        return userPhotosDataSource.count
    }
    

    var profileShareStatus : CurrentUserShareState? {
        return self.channel?.shareState
    }
    
    private(set) var channelUid: String?
    private(set) var channel: Channel?
    private var token: NotificationToken?
    
    var user: User? {
        return channel?.otherUsers.first
    }
    
    init(channelUid: String) {
        super.init()
        self.channelUid = channelUid
        fetchTags()
    }
    
    private func fetchTags() {
        let results = RealmUtils.fetch(ProfileTag.self)
        results.forEach { tag in
            self.tagsDatasource[tag.uid] = tag
        }
    }
    
    private func observeChannel() {
        
        guard let uid = self.channelUid else { return }
        
        setChannel(channel: RealmUtils.first(type: Channel.self, uid))
        
        self.token = RealmUtils.observe(uid: uid) {[weak self] (change: ObjectChange<Channel>) in
            switch change {
            case .change(let channel, _):
                self?.setChannel(channel: channel)
            default: break
            }
        }
    }
    
    private func setChannel(channel: Channel?) {
        self.channel = channel
        self.initDatasources()
        self.view?.reloadView()
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.observeChannel()
    }
    
    func settingsItem(atIndexPath indexPath: IndexPath) -> UserProfileItem? {
        guard indexPath.row < datasource.count else { return nil }
        return datasource[indexPath.row]
    }
    
    func userPhoto(atIndexPath indexPath: IndexPath) -> URL {
        return userPhotosDataSource[indexPath.row]
    }
    
    func initDatasources() {
        self.datasource.removeAll()
        
        if let age = self.user?.ageYear {
            self.datasource.append(
                .init(image: "ic_profile_info",
                      title: "Age",
                      subTitle:  String(age),
                      style: .style2,
                      type: .birthDate)
            )
        }
        
        if let gender = self.user?.gender {
            self.datasource.append(
                .init(image: nil,
                      title: "Gender",
                      subTitle: gender,
                      style: .style2,
                      type: .gender)
            )
        }
        
        self.datasource.append(
            .init(image: nil,
                  title: "Interests",
                  subTitle: self.user?.tagsStr,
                  style: .style2,
                  type: .tags)
        )
        
        self.updateImages()
    }
    
    private func updateImages() {
        let dispatchGroup = DispatchGroup()
        let queue = DispatchQueue.main
        self.userPhotosDataSource.removeAll()
        
        self.user?.photoGallery.forEach({ (url) in
            dispatchGroup.enter()
            SDWebImageManager.shared.loadImage(with: url, options: .queryDiskDataSync, context: nil, progress: nil) { (image, data, error, type, ok, url) in
                if let url = url, error == nil {
                    self.userPhotosDataSource.append(url)
                }
                
                queue.async {
                    dispatchGroup.leave()
                }
            }
        })
        
        dispatchGroup.notify(queue: queue) {
            self.view?.reloadView()
        }
    }
    
}

