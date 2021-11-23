//
//  CircleUserImageView.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 12.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

class CircleUserImageView: CircleImageView {
    
    private var user: User?
    private var channel: Channel!
    
    func set(user: User?, channel: Channel?) {
        self.user = user
        self.channel = channel
        self.setup()
    }

    private func setup() {
        
        if let user = self.user {
            self.setImageFromUrl(user.photoUrl, placeholderImg: #imageLiteral(resourceName: "profile"))
        } else if let channel = channel {
            self.setImageFromUrl(channel.recipientPhotoURL, placeholderImg: #imageLiteral(resourceName: "profile")) { [weak self] image, error in
                if error == nil {
                    channel.isProfileShared ? self?.unlockUser() : self?.lockUser()
                }
            }
        }
    }
    
    private func lockUser(){
        self.blurEffect()
    }
    
    private func unlockUser(){
        self.removeBlur()
    }
}
