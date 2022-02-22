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
    
    lazy var checkBoxView: CircleImageView = {
        let imageView = CircleImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "select")
        imageView.backgroundColor = .white
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
        
        self.addSubview(checkBoxView)
        checkBoxView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(20)
            make.height.equalTo(checkBoxView.snp.width).multipliedBy(1)
        }

    }
    
    func willDisplayCell() {
        
    }
    
    func willEndDisplayCell() {
        NotificationCenter.default.removeObserver(self)
    }
}
