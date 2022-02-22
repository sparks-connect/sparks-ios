//
//  TripPurposeController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 03/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripPurposeController: TripBaseController {
    
    let presenter = TripPurposePresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override var titleText: String{
        return "Purpose"
    }
    
    private lazy var tagsView: TagsView<PurposeEnum> = {
        let tagsView = TagsView<PurposeEnum>()
        tagsView.contentTags = PurposeEnum.allCases
        tagsView.currentSelections = [PurposeEnum.allCases.first?.rawValue ?? 0]
        return tagsView
    }()
    
    override func configure() {
        super.configure()
        
        self.view.addSubview(tagsView)
        tagsView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview().offset(-40)
            make.height.equalTo(48)
        }
    }
    
    override func nextClicked() {
        guard let rawValue = self.tagsView.currentSelections.last else { return}
        let purpose = PurposeEnum(rawValue: rawValue as! Int)
        self.presenter.save(info: self.info, purpose: purpose ?? .leisure)
    }
    
}

extension TripPurposeController: PurposeView {
    func navigate() {
        self.pageViewController?.switchTabToNext(parameters: nil)
    }
}

