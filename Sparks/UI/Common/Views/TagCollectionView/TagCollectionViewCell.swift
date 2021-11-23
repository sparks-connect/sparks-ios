//
//  TagCollectionViewCell.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 22.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "check"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private(set) lazy var primaryLabel: UILabel = {
        let view = UILabel()
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        view.font = UIFont.font(for: 13, style: .regular)
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.isSelected = false
        self.primaryLabel.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.contentView.layer.cornerRadius = 8
        self.contentView.backgroundColor = Color.background.uiColor
        self.primaryLabel.textColor = .white
        self.imageView.tintColor = .white
        
        layout()
    }
    
    private func layout() {
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-4)
            make.size.equalTo(24)
        }
        
        self.contentView.addSubview(primaryLabel)
        primaryLabel.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.right.equalTo(imageView.snp.left).offset(-4)
        }
    }
    
    final func update(withString string: String) {
        self.primaryLabel.text = string.localizedLowercase
    }
    
    private var _added: Bool = false
    var added: Bool {
        set {
            _added = newValue
            
            if newValue {
                self.contentView.backgroundColor = Color.green.uiColor
                self.imageView.image = #imageLiteral(resourceName: "check")
            } else {
                self.contentView.backgroundColor = Color.purple.uiColor
                self.imageView.image = #imageLiteral(resourceName: "plus")
            }
        }
        get {
            return self._added
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
