//
//  ProfilePhotoAddPresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 8/1/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Firebase

protocol ProfilePhotoAddView: BasePresenterView {
    func showAuthorizationWindow(url: URL)
    func navigate(assets: [PhotoAsset])
}

class ProfilePhotoAddPresenter: BasePresenter<ProfilePhotoAddView> {
    var isProfilePic: Bool = false
    var next: String? = nil
    
    func uploadImage(image: UIImage) {
        guard  let data = image.compressed else { return }
        Service.auth.updatePhoto(data: data, main: true) { [weak self] response in
            self?.handleResponse(response: response)
        }
    }
    
    func showInstaAuthorization(){
        let url  = Service.insta.getAuthorizationURL()
        self.view?.showAuthorizationWindow(url: url)
    }
    
    func getInstaAccessToken(code: String){
        Service.insta.getAccessToken(code: code) {  [weak self] response in
            self?.getMedia()
        }
    }
    
    func getMedia(_ handler:((Bool, [PhotoAsset])->Void)? = nil) {
        Service.insta.getMedia(next: self.next, completion: { [weak self] response in
            var photos = [PhotoAsset]()
            switch response {
            case .success(let instaAsset):
                instaAsset?.data?.forEach({ media in
                    let url = URL(string: media.mediaUrl ?? "")
                    if  url != nil && media.mediaType != .video {
                        let photo = PhotoAsset(withURL: url!, id: media.id ?? "")
                        photos.append(photo)
                    }
                })
                if handler != nil {
                    let isPageAvailable = self?.next != instaAsset?.paging?.next
                    self?.next = isPageAvailable ? instaAsset?.paging?.next : nil
                    handler?(isPageAvailable, photos)
                }else {
                    self?.next = instaAsset?.paging?.next
                    self?.view?.navigate(assets: photos)
                }
            case .failure(_):
                // process again
                let url  = Service.insta.getAuthorizationURL()
                self?.view?.showAuthorizationWindow(url: url)
            }
        })
    }
    
    func fetchNextMedia(completion:@escaping (Bool, [PhotoAsset])->Void){
        if self.next != nil {
            self.getMedia(completion)
        }
    }
    
    func sendPhotos(photos: [PhotoAsset]){
        background {
            Service.auth.updatePhotos(urls: photos.compactMap({ $0.url }), mainIndex: self.isProfilePic ? 0 :  nil) { [weak self] response in
                self?.handleResponse(response: response)
            }
        }
        
    }
    
}
