//
//  Cell.swift
//  cario
//
//  Created by Irakli Vashakidze on 6/27/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate: class {}

class CollectionViewCell: UICollectionViewCell {
    private(set) var indexPath: IndexPath!
    private(set) var section: Int!
    private(set) weak var delegate: CollectionViewCellDelegate?
    
    func configure(indexPath: IndexPath, delegate: CollectionViewCellDelegate?, section: Int) {
        self.indexPath = indexPath
        self.delegate = delegate
        self.section = section
    }
    
    func willDisplayCell() {
        
    }
    
    func willEndDisplayCell() {
        NotificationCenter.default.removeObserver(self)
    }
}
