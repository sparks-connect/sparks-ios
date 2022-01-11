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
    func didAddProfilePhoto()
}

class ProfilePhotoAddPresenter: BasePresenter<ProfilePhotoAddView> {
    func uploadImage(image: UIImage) {
        guard  let data = image.compressed else { return }
        Service.auth.updatePhoto(data: data, main: true) { [weak self] response in
            self?.handleResponse(response: response)
        }
    }
}
