//
//  NavigationBar.swift
//  Sparks
//
//  Created by Nika Samadashvili on 6/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

protocol NavigationBarDelegate : AnyObject {
    func didBackCancelButton()
}


class NavigationBar : BaseView {
    
    weak var delegate : NavigationBarDelegate?
    
    var title : String = "" {
        willSet { self.titleLabel.text = newValue }
    }
    
    private var backButton : UIButton = {
        var view = UIButton()
        view.setImage(#imageLiteral(resourceName: "ic_back"), for: .normal)
        return view
    }()
    
    private var titleLabel : UILabel = {
        var view = UILabel()
        view.contentMode = .center
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return view
    }()
    
    override func configure() {
        super.configure()
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        layout()
    }
    
    
    private func layout(){
        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(24)
        }
        
         addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
    }
    
    @objc private func didTapBackButton(){
        self.delegate?.didBackCancelButton()
    }
    
}
