//
//  ExploreController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 01.04.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import UIKit

class HomeController: BaseController {
    
    private let presenter = HomePresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
      
    lazy private var listView : ListView = {
        let view = ListView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Trips"
        layout()
        setupListView()
    }
    
    override func didAppear() {
        super.didAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authorizationChanged),
                                               name: Consts.Notifications.didChangeLocationPermissions,
                                               object: nil)
        enableLocation()
        addProfilePic()
    }
    
    private func setupListView(){
        listView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        listView.backgroundColor = UIColor.init(hex: "#1f1b24")
        listView.tintColor = .white
        listView.refreshControlIsEnabled = { return true }
        listView.cellClassIdentifiers = [TripsTableViewCell.description(): TripsTableViewCell.self]
        listView.cellReuseIdentifier = {(indexPath) in return TripsTableViewCell.description() }
        listView.heightForRow = {[weak self](indexPath) in
            let count = self?.presenter.tripsAt(indexPath: indexPath)?.trips.count ?? 0
            return count > 0 ? 400 : 100
        }
        listView.sectionCount = ({ return 1 })
        listView.cellDelegate = {(indexPath) in return self }
        listView.numberOfRows = {[weak self](section) in return self?.presenter.numberOfItems ?? 0 }
        listView.parameterForRow = {[weak self](indexPath) in return self?.presenter.tripsAt(indexPath: indexPath) }
        listView.willRefreshList = {[weak self] in self?.presenter.fetchTrips() }
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        if self.presenter.hasSearchFilters {
            let btn = BadgedButtonItem(with: UIImage(named: "search"))
            btn.setBadge(with: 0)
            btn.tapAction = {
                self.searchClicked()
            }
            return [btn]
        }
        return [UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchClicked))]
    }
    
    override func reloadView() {
        super.reloadView()
        self.configureNavigationBar()
        self.hideAnimatedActivityIndicatorView()
        self.listView.reloadData()
    }
    
    private func layout(){
        self.view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(8)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc private func searchClicked(){
        let controller = TripSearchController()
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    private func enableLocation(){
        if !LocationManager.sharedInstance.isLocationServiceEnabled() && User.current?.isMissingLocation == true {
            let controller = LocationEnableController()
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    private func addProfilePic() {
        if  User.current?.isMissingLocation == false && User.current?.isMissingPhoto == true {
            let controller = ProfilePhotoAddController()
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc private func authorizationChanged(notification: Notification) {
        main {
            self.addProfilePic()
        }
    }
}

extension HomeController: HomeView {
    func showLoader(isLoading: Bool) {
        if isLoading {
            self.displayAnimatedActivityIndicatorView()
        }
    }
    
}

extension HomeController: TripSearchControllerDelegate {
    func tripSearchControllerWillSearch() {
        self.navigationController?.pushViewController(TripsListController(), animated: true)
    }
}

extension HomeController: TripsTableViewCellDelegate {
    func willAddToFavourites(trip: Trip) {
        self.presenter.addToFavourite(trip: trip)
    }
    
    func didSelectTrip(trip: Trip) {
        let controller = TripInfoController(presenter: TripInfoPresenter(trip: trip))
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
