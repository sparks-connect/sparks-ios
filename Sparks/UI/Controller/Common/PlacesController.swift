//
//  PlacesController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 26/01/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
//import GooglePlaces
import UIKit
import CoreLocation

class PlacesController: BaseController {
    
    let presenter = PlacesPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    weak var delegate: Place?
    
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
    
    private lazy var searchField: UITextField = {
        let searchField = UITextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.clearButtonMode = .whileEditing
        searchField.textColor = .white
        searchField.font = Font.light.uiFont(ofSize: 16)
        searchField.becomeFirstResponder()
        searchField.attributedPlaceholder = NSAttributedString(
            string: "Search your city ....",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        if let clearButton = searchField.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = .white
        }
        searchField.addTarget(self, action: #selector(textFieldDidChange(textField:)),
                             for: .editingChanged)
        return searchField
    }()
    
    private lazy var closeIcon: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setBackgroundImage(UIImage(named: "close"), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        return btn
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorColor = UIColor.white
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func configure() {
        super.configure()
        self.layout()
    }
    
    override func didAppear() {
        super.didAppear()
    }
    
    func layout(){
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
        
        searchContainer.addSubview(searchField)
        searchField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(16)
            make.centerY.equalTo(searchIcon)
            make.trailing.equalTo(closeIcon.snp.leading).offset(-16)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(searchField.snp.leading).offset(-16)
            make.top.equalTo(searchContainer.snp.bottom)
            make.trailing.equalTo(closeIcon.snp.leading)
            make.height.equalTo(220)
        }


    }
    
    override func reloadView() {
        super.reloadView()
        self.tableView.reloadData()
    }
    
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }
}
extension PlacesController {
    @objc func textFieldDidChange(textField: UITextField) {
        self.presenter.textChanged(text: textField.text)
    }
}

extension PlacesController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        self.presenter.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.getLocation(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PlacesController: PlaceView {
    func dismiss(){
        self.presenter.sendLocation(place: self.delegate)
        self.close()
    }
}
