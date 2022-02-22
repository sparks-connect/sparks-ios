//
//  TripCell.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripCell: UICollectionViewCell{
    
    private var indexPath: IndexPath!
    var makeFavourite: ((IndexPath) -> Void)?
    
    private lazy var imgView: UIImageView = {
        let imageVw = UIImageView()
        imageVw.translatesAutoresizingMaskIntoConstraints = false
        imageVw.contentMode = .scaleAspectFill
        imageVw.clipsToBounds = true
        return imageVw
    }()
    
    private lazy var dateBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = Color.fb.uiColor
        btn.isUserInteractionEnabled = false
        btn.setImage(UIImage(named: "calender"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = Font.light.uiFont(ofSize: 12)
        btn.layer.cornerRadius = 12
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        return btn
    }()
    
    private lazy var likeBtn: CircleButton = {
        let btn = CircleButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(fav(sender:)), for: .touchUpInside)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btn.setImage(UIImage(named: "like"), for: .normal)
        return btn
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layer.cornerRadius = 2
        stack.backgroundColor = Color.profile.uiColor
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.addRightShadow(with: 4, width: 4, color: UIColor.black.withAlphaComponent(0.5))
        stack.layoutMargins = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private lazy var name: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.isUserInteractionEnabled = false
        btn.titleLabel?.font = Font.bold.uiFont(ofSize: 12)
        btn.titleLabel?.lineBreakMode = .byTruncatingTail
        btn.titleLabel?.minimumScaleFactor = 0.8
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.setImage(UIImage(named: "name-ring"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 0)
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    private lazy var location: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.isUserInteractionEnabled = false
        btn.titleLabel?.font = Font.bold.uiFont(ofSize: 12)
        btn.titleLabel?.minimumScaleFactor = 0.8
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.lineBreakMode = .byTruncatingTail
        btn.setImage(UIImage(named: "takeoff"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 0)
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    private lazy var desc: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 3
        lbl.textColor = Color.description.uiColor
        lbl.font = Font.light.uiFont(ofSize: 8)
        return lbl
    }()
    
    private lazy var profileView: UIView = {
        let vw = UIView()
        return vw
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.contentView.borderWidth = 2.0
        self.contentView.borderColor = .white
        
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(dateBtn)
        dateBtn.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.leading.equalTo(8)
            make.height.equalTo(24)
        }
        
        self.contentView.addSubview(likeBtn)
        likeBtn.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.trailing.equalTo(-8)
            make.height.equalTo(30)
            make.width.equalTo(likeBtn.snp.height).multipliedBy(1)
        }
        
        self.contentView.addSubview(stackView)
        let width = (UIScreen.main.bounds.width*0.44)/1.8
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalTo(width)
        }
        
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(location)
        stackView.addArrangedSubview(desc)
    }
    
    func configure(indexPath: IndexPath, url: String, date: String, name: String, location: String, desc: String, isFav: Bool = false){
        imgView.sd_setImage(with: URL(string: url), completed: nil)
        self.indexPath = indexPath
        self.dateBtn.setTitle(date, for: .normal)
        self.name.setTitle(name, for: .normal)
        self.location.setTitle(location, for: .normal)
        self.desc.text = desc
        self.likeBtn.setImage(isFav ? UIImage(named: "ic_heart_filled") : UIImage(named: "like"), for: .normal)
    }
    
    @objc func fav(sender: Any) {
        self.makeFavourite?(self.indexPath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
