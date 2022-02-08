//
//  TripDateController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 27/01/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TripDateController: TripBaseController {
    
    override var titleText: String {
        return "When ?"
    }
    
    private lazy var departureView: DateView = {
        let vw = DateView(tite: "Departure", img: UIImage(named: "depart") ?? .init(), selected: true)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.layer.borderWidth = 1.6
        vw.layer.cornerRadius = 16
        vw.layer.borderColor = Consts.Colors.borderSelected.cgColor
        vw.addTapGesture(target: self, selector: #selector(dateChanged(_:)))
        return vw
    }()
    
    private lazy var arrivalView: DateView = {
        let vw = DateView(tite: "Arrival", img: UIImage(named: "arrival") ?? .init(), selected: false)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.layer.borderWidth = 0.8
        vw.layer.cornerRadius = 16
        vw.layer.borderColor = Consts.Colors.border.cgColor
        vw.addTapGesture(target: self, selector: #selector(dateChanged(_:)))
        return vw
    }()
    
    override func configure() {
        super.configure()
        
        self.view.addSubview(departureView)
        departureView.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.width.equalToSuperview().multipliedBy(0.38)
            make.height.equalToSuperview().multipliedBy(0.36)
            make.centerY.equalToSuperview().offset(-32)
        }
        
        self.view.addSubview(arrivalView)
        arrivalView.snp.makeConstraints { make in
            make.trailing.equalTo(-24)
            make.width.equalTo(departureView)
            make.height.equalTo(departureView)
            make.centerY.equalToSuperview().offset(-32)
        }
        
    }
    
    override func reloadView() {
        super.reloadView()
    }
    
    override func didAppear() {
        super.didAppear()
    }
    
    @objc func dateChanged(_ tapRecognizer: UITapGestureRecognizer){
        if let vw = tapRecognizer.view as? DateView {
            self.loadFullnameEditMode(source: vw)
        }
    }
    
    private func loadFullnameEditMode(source: DateView) {
        let controller = OnKbdEditorViewController
            .createModule(text: source.title.text,
                          viewTitle: source.title.text ?? "",
                          inputTitle: source.getKey.rawValue,
                          placeholder: source.getKey.rawValue,
                          customKey: source.getKey.rawValue,
                          delegate: self)
        controller.inputKind = source.getKey.inputKind
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    override func nextClicked() {
        self.pageViewController?.switchTabToNext(parameters: nil)
    }
}

extension TripDateController: OnKbdEditorViewControllerDelegate {
    func onDone(with text: String?, pickerValue: String?, dateValue: __int64_t, customKey: String?) {
        let vw = [departureView,arrivalView].filter({$0.getKey.rawValue == customKey}).first
        vw?.setDate(date: dateValue.toDate)
    }
}

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
    
    init(tite: String, img: UIImage, selected: Bool){
        super.init(frame:.zero)
        layout()
        
        if selected {
            self.title.textColor = Consts.Colors.dateSelected
            self.date.textColor = Consts.Colors.dateSelected
        }
        
        self.title.text = tite
        self.imgView.image = img
        self.date.text = Date().toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
    }
    
    func setDate(date: Date){
        self.date.text = date.toString("dd MMM, yyyy", localeIdentifier:  Locale.current.identifier)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

