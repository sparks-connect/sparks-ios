//
//  CenterAlignedCollectionViewFlowLayout.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 22.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private var itemAttributesCache = [UICollectionViewLayoutAttributes]()
    private var headerAttributesCache = [UICollectionViewLayoutAttributes]()
    
    override final func prepare() {
        super.prepare()
        
        // Assumes one section for now.
        if let collectionView = self.collectionView, collectionView.numberOfItems(inSection: 0) > 0 {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            let headerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: firstIndexPath)
            headerLayoutAttributes.frame = CGRect(x: 0, y: 0, width: self.headerReferenceSize.width, height: self.headerReferenceSize.height)
            self.headerAttributesCache.append(headerLayoutAttributes)
            
            // Grab defaults from super.
            self.itemAttributesCache.removeAll() // For some reason, there is sometimes objects in here already, invalidateLayout() not getting called somewhere?
            for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                if let attributes = super.layoutAttributesForItem(at: indexPath) {
                    self.itemAttributesCache.append(attributes)
                }
            }
            
            // Now center the defaults from above.
            for item in self.itemAttributesCache {
                let sameRowAttributes = self.itemAttributesCache.filter { $0.frame.origin.y == item.frame.origin.y }
                
                // Calculate row width
                var rowWidth = sameRowAttributes.reduce(0.0, { (width, attribute) -> CGFloat in
                    return width + attribute.frame.size.width
                })
                rowWidth += self.minimumInteritemSpacing * CGFloat(sameRowAttributes.count - 1)
                
                // Calculate X value
                var startX = (collectionView.frame.size.width - rowWidth) / 2
                for layoutAttributes in sameRowAttributes {
                    layoutAttributes.frame.origin.x = startX
                    startX = layoutAttributes.frame.maxX + self.minimumInteritemSpacing
                }
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let headerAttributes = self.headerAttributesCache.filter { $0.frame.intersects(rect) }
        let itemAttributes = self.itemAttributesCache.filter { $0.frame.intersects(rect) }
        return headerAttributes + itemAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.itemAttributesCache.first { $0.indexPath == indexPath }
    }
    
    override final func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return self.headerAttributesCache.first { $0.indexPath == indexPath }
        }
        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if self.scrollDirection == .vertical, let oldWidth = self.collectionView?.bounds.width {
            return oldWidth != newBounds.width
        } else if scrollDirection == .horizontal, let oldHeight = self.collectionView?.bounds.height {
            return oldHeight != newBounds.height
        }
        
        return false
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        self.itemAttributesCache.removeAll()
        self.headerAttributesCache.removeAll()
    }
    
}

