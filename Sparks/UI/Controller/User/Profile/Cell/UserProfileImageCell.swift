//
//  UserProfileImageCell.swift
//  Sparks
//
//  Created by George Vashakidze on 6/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

protocol UserProfileImageCellDelegate: TableViewCellDelegate {
    func didTapAtIndex(_ index: Int)
}

class UserProfileImageCell: TableViewCell {
    
    @IBOutlet var imageViews: [ImageView]!
    
    override var reuseIdentifier: String? {
        return "UserProfileImageCell"
    }
    
    override func willDisplayCell() {
        
        guard let user = User.current else { return }
        
        
        setImage(url: user.photoUrl, index: 0)
        
        let others = user.otherUrls
        if others.count > 0 {
            setImage(url: others[0], index: 1)
        } else {
            setImage(url: "", index: 1)
        }
        
        if others.count > 1 {
            setImage(url: others[1], index: 2)
        } else {
            setImage(url: "", index: 2)
        }
    }
    
    private func setImage(url: String, index: Int) {
        imageViews[index].contentMode = .center
        guard let url = URL(string: url) else { return }
        imageViews[index].sd_setImage(
            with: url,
            placeholderImage: Image.noImage.uiImage,
            options: .refreshCached) {[weak self] (image, err, cacheType, url) in
            main { self?.handleImageDownloaded(image: image, at: index) }
        }
    }
    
    private func handleImageDownloaded(image: UIImage?, at index: Int) {
        if let img = image {
            self.imageViews[index].image = img
            self.imageViews[index].contentMode = .scaleAspectFill
        } else {
            self.imageViews[index].image = Image.noImage.uiImage
            self.imageViews[index].contentMode = .center
        }
    }
    
    private func setUpImageUrl(with imageName: String) -> String {
        guard let userId = User.current?.uid else { return "" }
        return "\(Consts.Firebase.firaStorageBaseUrl)\(userId)%2F\(imageName)?alt=media"
    }
    
    @IBAction func didTapAtImage(button: UIButton) {
        (delegate as? UserProfileImageCellDelegate)?.didTapAtIndex(button.tag)
    }
}
