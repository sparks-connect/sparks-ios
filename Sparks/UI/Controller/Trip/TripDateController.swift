//
//  TripDateController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 27/01/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripDateController: TripBaseController {
    
    let presenter = TripDatePresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override var titleText: String {
        return "When ?"
    }
    
    private lazy var departureView: DateView = {
        let vw = DateView(tite: "Departure", img: UIImage(named: "depart") ?? .init(), selected: true)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.addTapGesture(target: self, selector: #selector(dateChanged(_:)))
        return vw
    }()
    
    private lazy var arrivalView: DateView = {
        let vw = DateView(tite: "Arrival", img: UIImage(named: "arrival") ?? .init(), selected: false)
        vw.translatesAutoresizingMaskIntoConstraints = false
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
        self.presenter.save(info: self.info, startDate: departureView.getDate, endDate: arrivalView.getDate)
    }
}

extension TripDateController: OnKbdEditorViewControllerDelegate {
    func onDone(with text: String?, pickerValue: String?, dateValue: __int64_t, customKey: String?) {
        let vw = [departureView,arrivalView].filter({$0.getKey.rawValue == customKey}).first
        vw?.setDate(date: dateValue.toDate)
    }
}

extension TripDateController: TripDateView {
    func navigate() {
        self.pageViewController?.switchTabToNext(parameters: nil)
    }
}
