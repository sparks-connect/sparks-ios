//
//  AlbumSelectionViewController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import UIKit
import Photos
import RxSwift

protocol AssetSelectViewControllerDelegate: AnyObject {
    
    func assetsSelected(assets: [PhotoAsset])
    
}

class AssetSelectViewController: BaseController, CollectionViewCellDelegate {
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: "R.reuseIdentifier.assetCollectionViewCell")
        return collection
    }()
    var maxSelectionCount = 10
    var assets: PHFetchResult<PHAsset>? {
        didSet {
            self.photoAssets.removeAll()
            self.assets?.enumerateObjects { (asset, start, stop) in
                let photoAsset = PhotoAsset(withAsset: asset)
                self.photoAssets.append(photoAsset)
            }
        }
    }
    
    private lazy var exploringButton: PrimaryButton = {
        let view = PrimaryButton()
        view.setTitle("Start exploring", for: .normal)
        view.addTarget(self, action: #selector(startExploring), for: .touchUpInside)
        view.layer.cornerRadius = 32
        return view
    }()
    
    var photoAssets = [PhotoAsset]()
    private var selectedAssets = [PhotoAsset]()
    
    weak var delegate: AssetSelectViewControllerDelegate?
    
    private var previewItem: PhotoAsset?
    private var previewImageView: UIImageView?
    private var didSubmit = false
    
    override final func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        self.view.addSubview(exploringButton)
        
        collectionView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        exploringButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.left.equalToSuperview().inset(24)
            $0.right.equalToSuperview().inset(24)
            $0.height.equalTo(64)
        }
        
        self.collectionView.allowsMultipleSelection = self.maxSelectionCount > 1
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
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
            let isSatisfy = self.selectedAssets.allSatisfy({ $0.url != nil })
            if !isSatisfy{
                self.selectedAssets.forEach { asset in
                    asset.downloadFile {
                        if self.selectedAssets.last == asset {
                            self.delegate?.assetsSelected(assets: self.selectedAssets)
                        }
                    }
                }
            }else {
                self.delegate?.assetsSelected(assets: self.selectedAssets)
            }
        }
    }
    
    // MARK: Helpers
    
    private final func updateTitleForCount(_ count: Int) {
        if self.maxSelectionCount > 1 {
            self.title = count == 1 ? "\(count) item selected" : "\(count) items selected"
        }
    }
    
    @objc private final func startExploring(){
        self.didSubmit = true
        self.dismiss(animated: true, completion: nil)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "R.reuseIdentifier.assetCollectionViewCell", for: indexPath) as?  AssetCollectionViewCell else { return  UICollectionViewCell() }
        cell.setup()
        if let asset = assets?.object(at: indexPath.item) {
            cell.update(withAsset: asset)
        }else {
            cell.update(withPhoto: self.photoAssets[indexPath.item])
        }
        return cell
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
