//
//  MainTabBarController.swift
//  SportsStars
//
//  Created by George Vashakidze on 2/5/20.
//  Copyright © 2020 SportsStars. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftUI

class MainTabBarController: UITabBarController {
    
    private var channelsToken: NotificationToken?
    private var count: Int = 0
    
    struct Sizes {
        static let kHeight: CGFloat = 60
        static let kPaddingFromBottom: CGFloat = 90
        static let kWidth: CGFloat = 220
    }
    
    private let tripListController = UINavigationController(rootViewController: TripsListController())
    private let channelListController = UINavigationController(rootViewController: ChannelListController())
    private let addTripController = UINavigationController(rootViewController: TripsListController())
    private let favourites = UINavigationController(rootViewController: TripFavouriteController())
    private let settingsController = UINavigationController(rootViewController: ProfileController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.configureTabbar()
        // call super after configuration, otherwise App get crashed
        observeChannels()
    }
    
    private func observeChannels() {
        // TODO: This count need to be set on UI
        channelsToken?.invalidate()
        channelsToken = Channel.observeUnreadCounts({ count in
            self.count = count
        })
    }
    
    private func configureTabbar() {
        self.tabBar.barTintColor = .black
        self.tabBar.tintColor = .white
        self.tabBar.isTranslucent = false
        let trips = UITabBarItem(title: "", image: UIImage(named: "ic_tab_search"), selectedImage: UIImage(named: "ic_tab_search"))
        trips.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 8)
        trips.imageInsets = UIEdgeInsets.init(top: 8,left: 0,bottom: 0,right: 0)

        tripListController.tabBarItem = trips
        
        let connections = UITabBarItem(title: "Connections", image: UIImage(named: "ic_tab_connections"), selectedImage: UIImage(named: "ic_tab_connections"))
        connections.imageInsets = UIEdgeInsets.init(top: 8,left: 0,bottom: 0,right: 0)
        channelListController.tabBarItem = connections
        
        let createTrip = UITabBarItem(title: "", image: nil, selectedImage: nil)
        createTrip.imageInsets = UIEdgeInsets.init(top: 8,left: 0,bottom: 0,right: 0)
        addTripController.tabBarItem = createTrip
        
        let favs = UITabBarItem(title: "Favourites", image: UIImage(named: "ic_tab_favourite"), selectedImage: UIImage(named: "ic_tab_favourite"))
        favs.imageInsets = UIEdgeInsets.init(top: 8,left: 0,bottom: 0,right: 0)
        favourites.tabBarItem = favs
        
        let prof = UITabBarItem(title: "Profile", image: UIImage(named: "ic_tab_profile"), selectedImage: UIImage(named: "ic_tab_profile"))
        prof.imageInsets = UIEdgeInsets.init(top: 8,left: 0,bottom: 0,right: 0)
        settingsController.tabBarItem = prof
        
        self.viewControllers = [tripListController, channelListController, addTripController, favourites, settingsController]
        
        self.tabBar.items?.forEach({
            $0.title = nil
        })
        
        let view = CenterView(frame: CGRect(x: self.tabBar.center.x-24, y: 16, width: 54, height: 54))
        self.tabBar.addSubview(view)
        view.didTapButton = {[unowned self] in
            self.openCreateTrip()
        }
    }
    
    private func addProfilePic() {
        if LocationManager.sharedInstance.isLocationServiceEnabled() && User.current?.isMissingPhoto == true {
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
    
    private func getPurchaseController() -> UIViewController {
        let controller = PurchaseOptionsController()
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
    
    func newAction(){
        
        var controller: UIViewController = getPurchaseController()
        let hasBalance = User.current?.hasFreeBalance == true
        if (hasBalance) {
            controller = UINavigationController(rootViewController: NewMessagePageViewController())
        }
        
        self.present(controller, animated: hasBalance, completion: nil)
    }
    
    @objc func openCreateTrip(){
        let controller = CreateTripController()
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: false, completion: nil)
    }
    
    func presentChannel(withID: String){
        let chatController = ChatController(channelUid: withID)
        channelListController.popToRootViewController(animated: false)
        channelListController.pushViewController(chatController, animated: false)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        
        // Your middle tab bar item index.
        // In my case it's 1.
        if selectedIndex == 2 {
            return false
        }
        
        return true
    }
}
