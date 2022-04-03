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

import UIKit

class CustomTabBar: UITabBar {
    
    // MARK: - Variables
    public var didTapButton: (() -> ())?
    
    public lazy var middleButton: UIButton! = {
        let middleButton = UIButton()
        
        middleButton.frame.size = CGSize(width: 48, height: 48)
        
        let image = UIImage(systemName: "plus")!
        middleButton.setImage(image, for: .normal)
        middleButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        middleButton.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.4117647059, blue: 0.3803921569, alpha: 1)
        middleButton.tintColor = .white
        middleButton.layer.cornerRadius = 8
        
        middleButton.addTarget(self, action: #selector(self.middleButtonAction), for: .touchUpInside)
        
        self.addSubview(middleButton)
        
        return middleButton
    }()
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        middleButton.center = CGPoint(x: frame.width / 2, y: -5)
    }
    
    // MARK: - Actions
    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?()
    }
    
    // MARK: - HitTest
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        
        return self.middleButton.frame.contains(point) ? self.middleButton : super.hitTest(point, with: event)
    }
}

class MainTabBarController: UITabBarController {
    
    private var channelsToken: NotificationToken?
    private var count: Int = 0
    let centerButton = CenterView(frame: CGRect(x: 0, y: 16, width: 54, height: 54))
    
    struct Sizes {
        static let kHeight: CGFloat = 60
        static let kPaddingFromBottom: CGFloat = 90
        static let kWidth: CGFloat = 220
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        centerButton.frame.size.width = 54
        centerButton.frame.size.height = 54
        centerButton.frame.origin.y = 16
        centerButton.center.x = self.tabBar.center.x
    }

    private let tripListController = UINavigationController(rootViewController: HomeController())
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
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Color.fadedBackground.uiColor
        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }
        
        let trips = UITabBarItem(title: "", image: UIImage(named: "ic_tab_search"), selectedImage: UIImage(named: "ic_tab_search"))
        trips.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 8)
        trips.imageInsets = UIEdgeInsets.init(top: 8,left: 0,bottom: 0,right: 0)

        tripListController.tabBarItem = trips
        self.tabBar.isTranslucent = false
        let connections = UITabBarItem(title: "Connections", image: UIImage(named: "ic_tab_connections"), selectedImage: UIImage(named: "ic_tab_connections"))
        connections.imageInsets = UIEdgeInsets.init(top: 8,left: 0,bottom: 0,right: 0)
        channelListController.tabBarItem = connections
        
        let createTrip = UITabBarItem(title: nil, image: nil, selectedImage: nil)
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
        
        self.tabBar.insertSubview(centerButton, aboveSubview: self.tabBar)
        centerButton.didTapButton = {[unowned self] in
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
