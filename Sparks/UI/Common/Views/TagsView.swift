//
//  TagsView.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

protocol Tag: CaseIterable, RawRepresentable {
    func getLabel() -> String
}

class TagsView<T: Tag>: BaseView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var contentTags: [T] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    internal var currentSelections = [Any]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var didSelectItem: ((IndexPath) -> Void)?
    var cellSize: CGSize = CGSize(width: 150, height: 32)
    var equalSizeCount: Int = 2
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = CenterAlignedCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = cellSize
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 12
        flowLayout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        let view = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: flowLayout)
        view.allowsMultipleSelection = true
        view.backgroundColor = Color.background.uiColor
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(TagCell.self, forCellWithReuseIdentifier: "cell")
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
    
    private final func tagIsSelected(_ tag: T) -> Bool {
        if tag.rawValue is Int {
            return self.currentSelections.filter({ $0 as? Int == tag.rawValue as? Int}).count > 0
        }
        return self.currentSelections.filter({ $0 as? String == tag.rawValue as? String}).count > 0
    }
    
    internal final func updateCell(atIndexPath indexPath: IndexPath) {
        if !self.tagIsSelected(self.contentTags[indexPath.row]){
            self.currentSelections.removeLast()
            self.currentSelections.append(self.contentTags[indexPath.row].rawValue)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.updateCell(atIndexPath: indexPath)
        self.didSelectItem?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.updateCell(atIndexPath: indexPath)
        self.didSelectItem?(indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.contentTags.count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TagCell {
            let contentTag = self.contentTags[indexPath.row]
            cell.added = self.tagIsSelected(contentTag)
            cell.update(withString: contentTag.getLabel())
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentTag = self.contentTags[indexPath.row]
        if self.contentTags.count == equalSizeCount {
            return cellSize
        }
        return CGSize(width: contentTag.getLabel().size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width + 20, height: cellSize.height)
        
    }
    
}


class TagCell: UICollectionViewCell {
    
    private lazy var title: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = Font.light.uiFont(ofSize: 14)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.sizeToFit()
        return lbl
    }()
    
    private var _added: Bool = false
    var added: Bool {
        set {
            _added = newValue
            
            if newValue {
                self.contentView.backgroundColor = Color.purple.uiColor
            } else {
                self.contentView.backgroundColor = Consts.Colors.border
            }
        }
        get {
            return self._added
        }
    }
    
    final func update(withString string: String) {
        self.title.text = string
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.contentView.backgroundColor = Consts.Colors.border
        self.contentView.layer.cornerRadius = 16.0
        self.contentView.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
