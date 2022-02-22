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
    
    private lazy var tripView: TripView = {
        let vw = TripView(presenter: self.presenter)
        return vw
    }()
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Sparks"
        layout()
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        return [UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchClicked))]
    }
    
    override func reloadView() {
        super.reloadView()
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
}

extension TripsListController: TripListView {
    func navigate(presenter: TripInfoPresenter) {
        let controller = TripInfoController(presenter: presenter)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
