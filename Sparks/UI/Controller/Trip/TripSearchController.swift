//
//  TripSearchController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 09/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripSearchController: BaseController {
    
    private let presenter = TripSearchPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private lazy var searchContainer: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    private lazy var searchIcon: UIImageView = {
        let img = UIImageView(image: UIImage(named: "search"))
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private lazy var searchLabel: UILabel = {
        let lbl = Label()
        lbl.textAlignment = .left
        lbl.font =  UIFont.systemFont(ofSize: 16, weight:.light)
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.alpha = 0.4
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.text = "Type city name..."
        lbl.isUserInteractionEnabled = true
        lbl.addTapGesture(target: self, selector: #selector(navigateToPlaces))
        return lbl
    }()
    
    private lazy var closeIcon: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setBackgroundImage(UIImage(named: "close"), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        return btn
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Age"
        label.font = Font.light.uiFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private lazy var tagsAgeView: TagsView<Age> = {
        let tagsView = TagsView<Age>()
        tagsView.contentTags = Age.allCases
        tagsView.currentSelections = [Age.allCases.first?.rawValue ?? Age.small.rawValue]
        tagsView.equalSizeCount = 3
        tagsView.cellSize = CGSize(width:UIScreen.main.bounds.size.width*0.24, height:32)
        return tagsView
    }()
    
    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Gender"
        label.font = Font.light.uiFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private lazy var tagsGenderView: TagsView<Gender> = {
        let tagsView = TagsView<Gender>()
        tagsView.contentTags = Gender.allCases
        tagsView.currentSelections = [Gender.allCases.first?.rawValue ?? "Male"]
        tagsView.equalSizeCount = 3
        tagsView.cellSize = CGSize(width:UIScreen.main.bounds.size.width*0.24, height:32)
        return tagsView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dates"
        label.font = Font.light.uiFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    override func configure() {
        super.configure()
        self.layout()
    }
    
    override func didAppear() {
        super.didAppear()
    }
    
    private func layout(){
        self.view.addSubview(searchContainer)
        searchContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        
        searchContainer.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.leading.equalTo(16)
            make.width.equalTo(24)
            make.height.equalTo(searchIcon.snp.width).multipliedBy(1)
            
        }
        
        searchContainer.addSubview(closeIcon)
        closeIcon.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.trailing.equalTo(-16)
            make.width.equalTo(24)
            make.height.equalTo(closeIcon.snp.width).multipliedBy(1)
        }
        
        searchContainer.addSubview(searchLabel)
        searchLabel.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(16)
            make.centerY.equalTo(searchIcon)
            make.trailing.equalTo(closeIcon.snp.leading).offset(-16)
        }
        
        self.view.addSubview(ageLabel)
        ageLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.top.equalTo(searchContainer.snp.bottom).offset(48)
        }
        
        self.view.addSubview(tagsAgeView)
        tagsAgeView.snp.makeConstraints { make in
            make.top.equalTo(ageLabel.snp.bottom).offset(16)
            make.leading.equalTo(24)
            make.trailing.equalTo(-24)
            make.height.equalTo(48)
        }
        
        self.view.addSubview(genderLabel)
        genderLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.top.equalTo(tagsAgeView.snp.bottom).offset(48)
        }
        
        self.view.addSubview(tagsGenderView)
        tagsGenderView.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(16)
            make.leading.equalTo(genderLabel)
            make.trailing.equalTo(-24)
            make.height.equalTo(48)
        }
        
        self.view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.top.equalTo(tagsGenderView.snp.bottom).offset(48)
        }

    }
    
    @objc func navigateToPlaces(){
        let places = PlacesController()
        places.delegate = self.presenter
        self.present(places, animated: false, completion: nil)
    }
    
    @objc private func close(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension TripSearchController: TripSearchView {
    func updateLocation(text: String?) {
        self.searchLabel.text = text
    }
}
