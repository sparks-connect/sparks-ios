//
//  AssetCollectionViewCell.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import UIKit

import Photos.PHAsset
import MobileCoreServices

class AssetCollectionViewCell: CollectionViewCell {
    
//    @IBOutlet internal weak var imageView: UIImageView?
    @IBOutlet internal var detailView: UIView?
    @IBOutlet internal weak var detailLabel: UILabel?
    @IBOutlet weak var bottomDetailView: UIView?
    @IBOutlet weak var bottomDetailLabel: UILabel?
    
    var representedAssetIdentifier: String?
    
    private var request: PHImageRequestID?
    
    override final var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            if newValue {
                self.checkBoxView.alpha = 1
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.checkBoxView.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
                    self.imageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.checkBoxView.alpha = 0
                    self.imageView.alpha = 1
                }) { (completed) in
                    self.checkBoxView.transform = CGAffineTransform.identity
                }
            }
            super.isSelected = newValue
        }
    }
    
    override final func setup() {
        super.setup()
        
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.backgroundColor = UIColor.purple
        
        self.checkBoxView.alpha = 0
        
    }
    
    override final func reset() {
        super.reset()
        
        self.detailView?.isHidden = true
        self.bottomDetailView?.isHidden = true
        
        if let previousRequest = self.request {
            PHImageManager.default().cancelImageRequest(previousRequest)
            self.request = nil
        }
        self.imageView.image = nil
    }
    
    final func update(withAsset asset: PHAsset) {
        self.representedAssetIdentifier = asset.localIdentifier
        let size = CGSize(width: self.frame.size.width * UIScreen.main.scale, height: self.frame.size.height * UIScreen.main.scale)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { [weak self] image, _ in
            // The cell may have been recycled by the time this handler gets called, set the image only if we're still showing the same asset
            if self?.representedAssetIdentifier == asset.localIdentifier {
                self?.imageView.image = image
            }
        }
        
        if asset.mediaType == .video {
            self.bottomDetailView?.isHidden = false
            //self.bottomDetailLabel?.text = "\(asset.duration.stringFromTimeInterval())"
        } else if let typeIdentifier = asset.value(forKey: "uniformTypeIdentifier") as? String, typeIdentifier == (kUTTypeGIF as String) {
            self.detailView?.isHidden = false
            self.detailLabel?.text = "GIF"
        }

    }
    
    final func update(withPhoto photo: PhotoAsset) {
        self.imageView.sd_setImage(with: photo.url) { img, err, cache, url in
            if err != nil {
                print(err?.localizedDescription ?? "")
            }
        }
    }
    
}
