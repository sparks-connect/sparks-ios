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
    
    func getMedia() {
        Service.insta.getMedia(completion: { [weak self] response in
            var photos = [PhotoAsset]()
            switch response {
            case .success(let instaAsset):
                instaAsset?.data?.forEach({ media in
                    if let url = URL(string: media.mediaUrl ?? "") {
                        let photo = PhotoAsset(withURL: url, id: media.id ?? "")
                        photos.append(photo)
                    }
                })
            default:
                break
            }
            
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.navigate(assets: photos)
            })
        })
    }
    
    func sendPhotos(photos: [PhotoAsset]){
        background {
            Service.auth.updatePhotos(urls: photos.compactMap({ $0.url })) { [weak self] response in
                self?.handleResponse(response: response)
            }
        }
        
    }
    
}
