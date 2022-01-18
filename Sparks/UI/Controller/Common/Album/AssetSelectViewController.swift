//
//  AlbumSelectionViewController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import UIKit
import Photos

protocol AssetSelectViewControllerDelegate: AnyObject {
    
    func assetsSelected(assets: [PhotoAsset])
    
}

class AssetSelectViewController: BaseController {
    
    var collectionView: UICollectionView?
    var maxSelectionCount = 0
    var assets: PHFetchResult<PHAsset>? {
        didSet {
            self.photoAssets.removeAll()
            self.assets?.enumerateObjects { (asset, start, stop) in
                let photoAsset = PhotoAsset(withAsset: asset)
                self.photoAssets.append(photoAsset)
            }
        }
    }
    
    private var photoAssets = [PhotoAsset]()
    private var selectedAssets = [PhotoAsset]()
    
    weak var delegate: AssetSelectViewControllerDelegate?
    
    private var previewItem: PhotoAsset?
    private var previewImageView: UIImageView?
    private var didSubmit = false
    
    override final func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.allowsMultipleSelection = self.maxSelectionCount > 1
        
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            // Only three columns on smaller screens, please.
            var columns: CGFloat = 4
            if UIScreen.main.bounds.width < 320 {
                columns = 3
            }
            let sideSize = (UIScreen.main.bounds.width - columns + 1) / columns
            flowLayout.itemSize = CGSize(width: sideSize, height: sideSize)
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 1
        }
        
    }
    
    override final func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.didSubmit {
            self.delegate?.assetsSelected(assets: self.selectedAssets)
        }
    }
    
    // MARK: Helpers
    
    private final func updateTitleForCount(_ count: Int) {
        if self.maxSelectionCount > 1 {
            self.title = count == 1 ? "\(count) item selected" : "\(count) items selected"
        }
    }
    
}

extension AssetSelectViewController: UICollectionViewDataSource {
    
    final func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    final func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoAssets.count
    }
    
    final func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let asset = assets?.object(at: indexPath.item) {
            //cell.update(withAsset: asset)
            //cell.delegate = self
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "R.reuseIdentifier.assetCollectionViewCell", for: indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension AssetSelectViewController: UICollectionViewDelegate {
    
    final func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedAssets.count < self.maxSelectionCount || self.maxSelectionCount == 0 {
            let item = self.photoAssets[indexPath.item]
            self.selectedAssets.append(item)
            
            self.updateTitleForCount(self.selectedAssets.count)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            self.deselectAsset(atIndexPath: indexPath)
        }
    }
    
    final func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.deselectAsset(atIndexPath: indexPath)
    }
    
    private final func deselectAsset(atIndexPath indexPath: IndexPath) {
        let item = self.photoAssets[indexPath.item]
        for selectedAsset in self.selectedAssets {
            if item == selectedAsset {
                self.selectedAssets.removeObject(selectedAsset)
                
                break
            }
        }
        self.updateTitleForCount(self.selectedAssets.count)
    }
    
}
