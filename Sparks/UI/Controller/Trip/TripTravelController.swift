//
//  TripTravelController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripTravelController: TripBaseController {
    
    let presenter = TripTravelPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override var titleText: String{
        return "I'm travelling"
    }
    
    private lazy var tagsView: TagsView<TripCommunityEnum> = {
        let tagsView = TagsView<TripCommunityEnum>()
        tagsView.contentTags = TripCommunityEnum.allCases
        tagsView.currentSelections = [TripCommunityEnum.allCases.first?.rawValue ?? 0]
        return tagsView
    }()
    
    override func configure() {
        super.configure()
        
        self.view.addSubview(tagsView)
        tagsView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview().offset(-40)
            make.height.equalTo(96)
        }
    }
    
    override func nextClicked() {
        guard let rawValue = self.tagsView.currentSelections.last else { return }
        let community = TripCommunityEnum(rawValue: rawValue as! Int)
        self.presenter.save(info: self.info, community: community ?? .alone)
    }
}

extension TripTravelController: TravelView {
    func navigate() {
        self.pageViewController?.switchTabToNext(parameters: nil)
    }
}
