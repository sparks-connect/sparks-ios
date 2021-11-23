//
//  GalleryView.swift
//  cario
//
//  Created by Irakli Vashakidze on 11/1/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
    
    func image(targetSize: CGSize) -> UIImage? {
        var result: UIImage?
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.isSynchronous = true
        PHImageManager.default().requestImage(for: self,
                                              targetSize: targetSize,
                                              contentMode: PHImageContentMode.default,
                                              options: requestOptions,
                                              resultHandler: { (currentImage, info) in
            result = currentImage
        })
        
        return result
    }
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput?.fullSizeImageURL)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

class GalleryView: UIView {
    
    var collectionView : UICollectionView!
    let accessQueue = DispatchQueue(label: "synchronized", attributes: .concurrent)
    private var selectedIndexPath: IndexPath?
    
    private func append(_ asset: PHAsset) {
        accessQueue.async(flags:.barrier) {
            self.images.append(asset)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.addSubview(self.collectionView)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }

        self.collectionView.register(UINib(nibName: "GalleryImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var images = [PHAsset]()
    
    func fetch() {
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        //set up fetch options, mediaType is image.
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        for i in 0..<smartAlbums.count {
            let assetCollection = smartAlbums[i];
            let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
            for j in 0..<assetsFetchResult.count {
                let asset = assetsFetchResult[j]
                self.append(asset)
            }
        }
        
        self.collectionView.reloadData()
    }
}

extension GalleryView : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell
        cell?.configure(indexPath: indexPath, delegate: self, section: 0)
        return cell ?? CollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? CollectionViewCell)?.willDisplayCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        collectionView.reloadData()
        main(block: {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }, after: 0.3)
    }
}

extension GalleryView : GalleryImagelCollectionViewCellDelegate {
    func galleryImagelCollectionViewCell(imageAtIndexPath indexPath: IndexPath) -> PHAsset? {
        return self.images[indexPath.row]
    }
    
    func galleryImagelCollectionViewCell(isSelectedAt indexPath: IndexPath) -> Bool {
        return indexPath.row == self.selectedIndexPath?.row
    }
    
    func galleryImagelCollectionViewCell(willSendAtIndexPath indexPath: IndexPath) {
        
    }
}
