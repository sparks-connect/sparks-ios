//
//  ImageLabel.swift
//  Sparks
//
//  Created by Nika Samadashvili on 3/2/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit


class ImageLabel : UIView {
    private(set) var imageView = CircleUserImageView()
    
    private lazy var labelView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        layout()
    }
    
    convenience init(image: UIImage?, label: String, textColor: UIColor = .white){
        self.init()
        labelView.text = label
        labelView.textColor = textColor
        
        if let image = image{
            imageView.image = image
        }
    }
 
    private func layout(){
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalTo(imageView.snp.height)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
        }
        
        addSubview(labelView)
        labelView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(imageView.snp.right).inset(-16)
        }
    }
    
    
    func set(_ channel: Channel?, user: User?) {
        imageView.set(user: user, channel: channel)
    }
    
    func setTextColor(_ color: UIColor){
        labelView.textColor = color
    }
    
    func setText(_ text: String){
        labelView.text = text
    }
    
    func setTextFont(_ font: UIFont){
        labelView.font = font
    }
    
    func setTintColor(_ color: UIColor) {
        imageView.tintColor = color
        labelView.textColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
