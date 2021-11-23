//
//  PhotoCell.swift
//  Sparks
//
//  Created by Nika Samadashvili on 8/26/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class PhotoCell: UICollectionViewCell {
    
    let imageView : ImageView = {
        var view = ImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.background.uiColor
        setupLayout()
    }
    
    func setupWith(image: UIImage) {
        self.imageView.image = image
    }

    func setupWith(url: URL)  {
        self.imageView.setImageFromUrl(url.absoluteString)
    }
    
    func blurUp(){
        self.imageView.blurEffect()
    }
    
    private func setupLayout() {
        addSubview(imageView)
        imageView.snp.makeConstraints{
            $0.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

