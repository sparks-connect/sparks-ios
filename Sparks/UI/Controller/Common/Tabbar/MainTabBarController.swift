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

class MainTabBarController: CardTabBarController {
    
    private var channelsToken: NotificationToken?
    private var count: Int = 0
    
    struct Sizes {
        static let kHeight: CGFloat = 60
        static let kPaddingFromBottom: CGFloat = 90
        static let kWidth: CGFloat = 220
    }
    
    private let tripListController = UINavigationController(rootViewController: TripsListController())
    private let channelListController = UINavigationController(rootViewController: ChannelListController())
    private let addTripController = UINavigationController(rootViewController: CreateTripContainer())
    private let favourites = UINavigationController(rootViewController: UIViewController())
    private let settingsController = UINavigationController(rootViewController: ProfileController())
    
    override func viewDidLoad() {
        self.configureTabbar()
        // call super after configuration, otherwise App get crashed
        super.viewDidLoad()
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
//        self.tabBar.barTintColor = Color.purple.uiColor
//        self.tabBar.tintColor = .white
//        self.tabBar.isTranslucent = false
        self.tabBarBackgroundColor = Color.buttonColor.uiColor
        self.tintColor = .white
        let trips = UITabBarItem(title: "Trips", image: UIImage(named: "ic_tab_search"), selectedImage: UIImage(named: "ic_tab_search"))
        tripListController.tabBarItem = trips
        
        let connections = UITabBarItem(title: "Connections", image: UIImage(named: "ic_tab_connections"), selectedImage: UIImage(named: "ic_tab_connections"))
        channelListController.tabBarItem = connections
        
        let createTrip = UITabBarItem(title: "", image: UIImage(named: "ic_plus"), selectedImage: UIImage(named: "ic_plus"))
        addTripController.tabBarItem = createTrip
        
        let favs = UITabBarItem(title: "Favourites", image: UIImage(named: "ic_tab_favourite"), selectedImage: UIImage(named: "ic_tab_favourite"))
        favourites.tabBarItem = favs
        
        let prof = UITabBarItem(title: "Profile", image: UIImage(named: "ic_profile"), selectedImage: UIImage(named: "ic_profile"))
        settingsController.tabBarItem = prof
        
        self.viewControllers = [tripListController, channelListController, addTripController, favourites, settingsController]
        
        self.tabBar.items?.forEach({
            $0.title = nil
        })
        
        
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
    
    func createTrip(){
        let controller = CreateTripController()
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func presentChannel(withID: String){
        let chatController = ChatController(channelUid: withID)
        channelListController.popToRootViewController(animated: false)
        channelListController.pushViewController(chatController, animated: false)
    }
}


class CreateTripContainer: BaseController {
    private var willAppearCalled: Bool = false
    override func configure() {
        super.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !willAppearCalled  {
            let controller = CreateTripController()
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
            willAppearCalled = true
        }else{
            self.tabBarController?.selectedIndex = 0
            willAppearCalled = false
        }
    }
}
