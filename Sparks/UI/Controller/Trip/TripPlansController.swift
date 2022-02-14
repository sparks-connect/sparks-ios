//
//  TripPlansController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 03/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripPlanController: TripBaseController{
    
    let presenter = TripPlanPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override var titleText: String {
        return "Plans ?"
    }
    
    override var buttonText: String {
        return "Preview"
    }
    
    let placeHolder = "I plan to visit ..."
    
    private lazy var planLabel: Label = {
        let lbl = Label()
        lbl.textAlignment = .left
        lbl.font =  UIFont.systemFont(ofSize: 20, weight:.light)
        lbl.numberOfLines = 5
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.alpha = 0.4
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.8
        lbl.text = "I plan to visit ..."
        lbl.isUserInteractionEnabled = true
        lbl.addTapGesture(target: self, selector: #selector(navigateToEditor))
        return lbl
    }()
    
    override func configure() {
        super.configure()
        
        self.view.addSubview(planLabel)
        planLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview().offset(-32)
            $0.left.equalTo(32)
            $0.right.equalTo(-32)
        }
    }
    
    @objc func navigateToEditor(){
        self.loadFullnameEditMode(type: .name, value: planLabel.text ?? "")
    }
    
    private func loadFullnameEditMode(type: EditKey, value: String) {
        let controller = OnKbdEditorViewController
            .createModule(text: value,
                          viewTitle: titleText,
                          inputTitle: titleText,
                          placeholder: titleText,
                          customKey: type.rawValue,
                          delegate: self)
        controller.inputKind = type.inputKind
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    override func nextClicked() {
        self.presenter.save(info: self.info, plan: self.planLabel.text)
    }
}

extension TripPlanController: OnKbdEditorViewControllerDelegate{
    func onDone(with text: String?, pickerValue: String?, dateValue: __int64_t, customKey: String?) {
        self.planLabel.text = text
    }
}

extension TripPlanController: PlanView {
    func navigate(records: [String : Any]?) {
        self.pageViewController?.switchTabToNext(parameters: records)
    }
}
