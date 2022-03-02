//
//  DateView.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class DateView: UIView {
    
    lazy var title: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = Font.light.uiFont(ofSize: 12)
        return lbl
    }()
    
    private lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private lazy var date: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = Font.regular.uiFont(ofSize: 14)
        return lbl
    }()
    
    var getKey: EditKey {
        EditKey(rawValue: self.title.text ?? "") ?? .departure
    }
    var isSelected: Bool {
        get {
            return self.isSelected
        }
        set {
            self.updateUI(isSelected: newValue)
        }
    }
    var getDate: Int64 = Date().milliseconds
    
    init(tite: String, img: UIImage, selected: Bool){
        super.init(frame:.zero)
        layout()
        self.title.text = tite
        self.imgView.image = img
        self.date.text = Date().toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
        self.getDate = Date().milliseconds
        self.isSelected = selected
    }
    
    func setDate(date: Date){
        self.getDate = date.milliseconds
        self.date.text = date.toString("dd MMM, yyyy", localeIdentifier:  Locale.current.identifier)
        self.isSelected = true
    }
    
    func layout(){
        self.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(imgView.snp.width).multipliedBy(1)
        }
        
        self.addSubview(date)
        date.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
        }
    }
    
    func updateUI(isSelected: Bool = false){
        self.layer.cornerRadius = 16
        self.imgView.image = self.imgView.image?.withRenderingMode(.alwaysTemplate)
        if isSelected {
            self.layer.borderWidth = 1.6
            self.layer.borderColor = Consts.Colors.borderSelected.cgColor
            self.imgView.tintColor = Consts.Colors.borderSelected
            self.title.textColor = Consts.Colors.dateSelected
            self.date.textColor = Consts.Colors.dateSelected
        }else {
            self.layer.borderWidth = 0.8
            self.imgView.tintColor = .white
            self.layer.borderColor = Consts.Colors.border.cgColor
            self.title.textColor = .white
            self.date.textColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

