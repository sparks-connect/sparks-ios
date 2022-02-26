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
        let vw = TripView(presenter: self.presenter)
        return vw
    }()
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Sparks"
        layout()
    }
    
    override func didAppear() {
        super.didAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authorizationChanged),
                                               name: Consts.Notifications.didChangeLocationPermissions,
                                               object: nil)
        
//        if !LocationManager.sharedInstance.isLocationServiceEnabled() && User.current?.isMissingLocation == true {
//             let controller = LocationEnableController()
//             controller.modalPresentationStyle = .overFullScreen
//             self.present(controller, animated: true, completion: nil)
//         }
        
        addProfilePic()
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        return [UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchClicked))]
    }
    
    override func reloadView() {
        super.reloadView()
        self.hideAnimatedActivityIndicatorView()
        self.tripView.reload()
    }
    
    private func layout(){
        self.view.addSubview(tripView)
        tripView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
        }
    }
    
    @objc private func searchClicked(){
        self.present(TripSearchController(), animated: true, completion: nil)
    }
    
    private func addProfilePic() {
//        if  User.current?.isMissingLocation == false && User.current?.isMissingPhoto == true {
        if User.current?.isMissingPhoto == true {
            let controller = ProfilePhotoAddController()
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
//        }
    }
    
    @objc private func authorizationChanged(notification: Notification) {
        main {
            self.addProfilePic()
        }
    }
}

extension TripsListController: TripListView {
    func showLoader(isLoading: Bool) {
        self.displayAnimatedActivityIndicatorView()
    }
    
    func navigate(presenter: TripInfoPresenter) {
        let controller = TripInfoController(presenter: presenter)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
