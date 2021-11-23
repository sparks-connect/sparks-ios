//
//  TagCollectionView.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 22.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

class TagCollectionView: BaseView {
    
    var contentTags: [ProfileTag] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    internal var currentSelections = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var didSelectItem: ((IndexPath) -> Void)?
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = CenterAlignedCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 150, height: 32)
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.minimumLineSpacing = 12
        flowLayout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        let view = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: flowLayout)
        view.allowsMultipleSelection = true
        view.backgroundColor = Color.background.uiColor
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    
    override func configure() {
        super.configure()

        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.collectionView.flashScrollIndicators()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if #available(iOS 12, *) {
            self.collectionView.collectionViewLayout.invalidateLayout() // This is an issue with iOS 12 https://stackoverflow.com/questions/51375566/in-ios-12-when-does-the-uicollectionview-layout-cells-use-autolayout-in-nib
        }
    }
    
    private final func tagIsSelected(_ tag: ProfileTag) -> Bool {
        return self.currentSelections.contains(tag.uid)
    }
    
    internal final func updateCell(atIndexPath indexPath: IndexPath) {
//        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        let contentTag = self.contentTags[indexPath.row]
//        if self.tagIsSelected(contentTag), let index = self.currentSelections.firstIndex(of: contentTag.uid) {
//            cell.isSelected = false
//        } else  {
//            if self.currentSelections.count < 10 {
//                cell.isSelected = true
//            } else {
//                self.collectionView.deselectItem(at: indexPath, animated: true)
//            }
//        }
    }
}

extension TagCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    internal final func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.updateCell(atIndexPath: indexPath)
        self.didSelectItem?(indexPath)
    }
    
    internal final func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.updateCell(atIndexPath: indexPath)
        self.didSelectItem?(indexPath)
    }
    
    internal final func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal final func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.contentTags.count
        default:
            break
        }
        return 0
    }
    
    internal final func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TagCollectionViewCell {
            let contentTag = self.contentTags[indexPath.row]
            cell.added = self.tagIsSelected(contentTag)
            cell.update(withString: contentTag.name ?? "")
            return cell
        }
        
        return UICollectionViewCell()
    }
}
