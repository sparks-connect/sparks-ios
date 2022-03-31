//
//  TripFavouriteController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 23/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripFavouriteController: BaseController {
    
    private let presenter = TripFavouritePresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    private lazy var tripView: TripView<TripFavouritePresenter> = {
        let vw = TripView(presenter: self.presenter)
        return vw
    }()
    
    override func configure(){
        super.configure()
        self.navigationItem.title = "Favourites"
        
        self.view.addSubview(tripView)
        tripView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
        }
    }
    
    override func reloadView() {
        super.reloadView()
        tripView.reload()
    }
}

extension TripFavouriteController: TripFavView {
    func navigate(presenter: TripInfoPresenter) {
        let controller = TripInfoController(presenter: presenter)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
