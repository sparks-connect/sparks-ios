//
//  GalleryImagelCollectionViewCell.swift
//  cario
//
//  Created by Irakli Vashakidze on 11/1/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import UIKit
import Photos

protocol GalleryImagelCollectionViewCellDelegate: CollectionViewCellDelegate {
    func galleryImagelCollectionViewCell(imageAtIndexPath indexPath: IndexPath) -> PHAsset?
    func galleryImagelCollectionViewCell(isSelectedAt indexPath: IndexPath) -> Bool
    func galleryImagelCollectionViewCell(willSendAtIndexPath indexPath: IndexPath)
}

class GalleryImageCollectionViewCell: CollectionViewCell {

    private weak var del: GalleryImagelCollectionViewCellDelegate? {
        return self.delegate as? GalleryImagelCollectionViewCellDelegate
    }
    
//    @IBOutlet private(set) weak var imageView: ImageView!
    @IBOutlet private(set) weak var blurContainerView: UIView!
    @IBOutlet private(set) weak var buttonSend: CircleLoadingButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonSend.setBorderColor(UIColor.white, forState: .normal)
        self.buttonSend.setBorderWidth(0.8, forState: .normal)
        self.buttonSend.setTintColor(UIColor.white, forState: .normal)
        self.buttonSend.setTitleColor(UIColor.white, for: .normal)
        
        self.buttonSend.setBackgroundColor(UIColor.clear, forState: .disabled)
        self.buttonSend.setBorderColor(UIColor.lightGray, forState: .disabled)
        self.buttonSend.setBorderWidth(0.8, forState: .disabled)
        self.buttonSend.setTintColor(UIColor.lightGray, forState: .disabled)
        self.buttonSend.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    override func willDisplayCell() {
        super.willDisplayCell()
        guard let del = self.del else { return }
        self.imageView.image = del.galleryImagelCollectionViewCell(imageAtIndexPath: self.indexPath)?.image(targetSize: self.bounds.size)
        let selected = del.galleryImagelCollectionViewCell(isSelectedAt: self.indexPath)
        self.blurContainerView.setVisible(selected)
    }
    
    @IBAction private func sendClicked(sender: CircleLoadingButton) {
        sender.isEnabled = false
        self.del?.galleryImagelCollectionViewCell(willSendAtIndexPath: self.indexPath)
        main(block: {
            sender.isEnabled = true
        }, after: 0.5)
    }
}
