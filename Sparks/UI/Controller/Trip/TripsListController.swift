//
//  TripsListController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 05/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripsListController: BaseController {
    
    private let presenter = TripListPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private lazy var tripView: TripView<TripListPresenter> = {
        let vw = TripView(presenter: self.presenter, paging: true)
        return vw
    }()
        
    override func configure() {
        super.configure()
        self.navigationItem.title = "Trips"
        layout()
    }
    
    override func reloadView() {
        super.reloadView()
        self.configureNavigationBar()
        self.hideAnimatedActivityIndicatorView()
        self.tripView.reload()
    }
    
    private func layout(){
        self.view.addSubview(tripView)
        tripView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.bottom.equalToSuperview()
        }
    }
    
}

extension TripsListController: TripListView {
    func showLoader(isLoading: Bool) {
        if isLoading {
            self.displayAnimatedActivityIndicatorView()
        }
    }
    
    func navigate(presenter: TripInfoPresenter) {
        let controller = TripInfoController(presenter: presenter)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
