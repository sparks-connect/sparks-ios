//
//  MyTripsController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 27/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class MyTripsController: BaseController {
    
    private var presenter = MyTripsPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    private lazy var tripView: TripView<MyTripsPresenter> = {
        let vw = TripView(presenter: self.presenter)
        return vw
    }()
    
    convenience init(presenter: MyTripsPresenter) {
        self.init()
        self.presenter = presenter
    }
    
    override func configure(){
        super.configure()
        self.navigationItem.title = self.presenter.isCurrentUser ? "My Trips" : "Trips"
        
        self.view.addSubview(tripView)
        tripView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
        }
    }
    
    override func reloadView() {
        super.reloadView()
        tripView.reload()
    }
}

extension MyTripsController: MyTripView {
    func navigate(presenter: TripInfoPresenter) {
        let controller = TripInfoController(presenter: presenter)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
