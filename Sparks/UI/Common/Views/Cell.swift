//
//  Cell.swift
//  cario
//
//  Created by Irakli Vashakidze on 6/27/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate: AnyObject {}

class CollectionViewCell: UICollectionViewCell {
    private(set) var indexPath: IndexPath!
    private(set) var section: Int!
    private(set) weak var delegate: CollectionViewCellDelegate?
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func configure(indexPath: IndexPath, delegate: CollectionViewCellDelegate?, section: Int) {
        self.indexPath = indexPath
        self.delegate = delegate
        self.section = section
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        
    }
    
    func setup() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func willDisplayCell() {
        
    }
    
    func willEndDisplayCell() {
        NotificationCenter.default.removeObserver(self)
    }
}
