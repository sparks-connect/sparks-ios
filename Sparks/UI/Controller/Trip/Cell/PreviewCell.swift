//
//  PreviewCell.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class PreviewCell: UITableViewCell {
    private lazy var icon: UIImageView = {
        let icn = UIImageView()
        icn.translatesAutoresizingMaskIntoConstraints = false
        return icn
    }()
    
    private lazy var title: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.font = Font.light.uiFont(ofSize: 16)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.setup()
    }
    
    private func setup(){
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(icon.snp.width).multipliedBy(1)
        }
        
        self.addSubview(title)
        title.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(16)
            make.top.equalTo(icon).offset(-3)
            make.trailing.equalToSuperview()
        }
    }
    
    func configure(icn: String?, text: String?){
        icon.image = UIImage(named: icn ?? "")
        title.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

