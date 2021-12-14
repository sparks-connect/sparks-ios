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

class MainTabBarController: UITabBarController {
    
    private var channelsToken: NotificationToken?
    private var count: Int = 0
    
    struct Sizes {
        static let kHeight: CGFloat = 60
        static let kPaddingFromBottom: CGFloat = 90
        static let kWidth: CGFloat = 220
    }
    
    private let channelListController = UINavigationController(rootViewController: ChannelListController())
    private let settingsController = UINavigationController(rootViewController: ProfileController())
    let tabbarView = MainTabbarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewControllers()
        self.configureTabbar()
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
        
        self.tabBar.items?.forEach({
            $0.title = nil
        })
        
        let backgroundImage = UIView()
        self.view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(320)
            make.height.equalTo(Sizes.kHeight)
        }
        
        self.view.addSubview(tabbarView)
        tabbarView.snp.makeConstraints { make in
            make.edges.equalTo(backgroundImage.snp.edges)
        }
        self.view.bringSubviewToFront(tabbarView)
        
        backgroundImage.bringSubviewToFront(tabbarView)
        
        tabbarView.delegate = self
    }
    
    private func setupViewControllers() {
        self.viewControllers = [channelListController, settingsController]
    }
    
    func move2(index: Int) {
        tabbarView.move2(index: index)
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
    
    func presentChannel(withID: String){
        let chatController = ChatController(channelUid: withID)
        channelListController.popToRootViewController(animated: false)
        channelListController.pushViewController(chatController, animated: false)
    }
}

extension MainTabBarController: MainTabbarViewDelegate {
    func didTapOnAction() {
        newAction()
    }
    
    func didTap(at item: MainTabbarViewState) {
        self.selectedIndex = item.rawValue
    }
}
