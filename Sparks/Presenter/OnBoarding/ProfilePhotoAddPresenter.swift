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

protocol ProfilePhotoAddView: BasePresenterView {
    func didAddProfilePhoto()
}

class ProfilePhotoAddPresenter: BasePresenter<ProfilePhotoAddView> {
    func uploadImage(image: UIImage) {
        guard let user = User.current, let data = image.compressed else { return }
        SDImageCache.shared.removeImage(forKey: user.photoUrl, withCompletion: nil)
//        API.storage.uploadFile(to: Consts.Firebase.userPhotoPath(uid: user.uid, index: 0),
//                               file: data,
//                               contentType: "image/jpeg",
//                               completion: {[weak self] (response) in
//            self?.handleResponse(response: response)
//        }, progressBlock: nil)
    }
}
