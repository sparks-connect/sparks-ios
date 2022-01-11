//
//  AppDelegate.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/9/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import RealmSwift
import FBSDKCoreKit
#if DEBUG
import FLEX
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private(set) var mainTabbar: MainTabBarController?
    private var channelsToken: NotificationToken?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        LocalStore.markFirstLaunch()
        API.setup()
        print("==== DOCUMENTS DIRECTORY =================================")
        print(FileUtils.getDocumentsDirectory())
        print("==========================================================")
        
        RealmUtils.configure()
        monitorLocationUpdatesIfNeeded(launchOptions: launchOptions)
        Service.tags.fetchTags()
        AppDelegate.updateRootViewController()
        self.setupNotification(application, completion: {(token, error) in })
        #if DEBUG
        FLEXManager.shared.showExplorer()
        #endif
        debugPrint(Date().currentUTCDateStr)
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }
    
    static var instance: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private var rootViewController: UIViewController? {
        
        // return TestViewController() // In-app purchases
        
        guard let user = User.current else {
            return OnboardingPageViewController()
        }
        
        Service.chat.startObserveChannels()
        Service.auth.startGPSTracking()
        self.setupTabbarAppearance()
        
        if mainTabbar == nil {
            mainTabbar = MainTabBarController()
        }
        
        return mainTabbar
    }
    
    func observeChannels() {
        
        channelsToken?.invalidate()
        channelsToken = RealmUtils.observeChannelRequests(completion: { [weak self] (result, _, _, _) in
            self?.processRequests(result: result)
        })
    }
    
    private func processRequests(result: Array<Channel>) {
        if !result.isEmpty && !(self.topMostViewController is ChannelRequestsController) {
            DispatchQueue.main.async {
                let contr = ChannelRequestsController()
                self.topMostViewController?.present(contr, animated: true, completion: nil)
            }
        }
    }
    
    private func setupTabbarAppearance() {
        let tabBar = UITabBar.appearance()
        tabBar.barTintColor = UIColor.clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
    }

    private func monitorLocationUpdatesIfNeeded(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        /** Enable this code if we decide to use `allowsBackgroundLocationUpdates`
         
        let locationUpdate = launchOptions?[UIApplication.LaunchOptionsKey.location] as? Bool ?? false
        if locationUpdate {
            Service.auth.startSignificantGPSMonitoring()
        }
        */
    }
    
    var topMostViewController: UIViewController? {
      
        var topController = self.window?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
      
        return topController
    }
}

extension UIApplication {
    class var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}

extension AppDelegate {
    static func updateRootViewController() {
        guard let instance = UIApplication.shared.delegate as? AppDelegate else { return }
        instance.window = UIWindow(frame: UIScreen.main.bounds)
        instance.window?.rootViewController = instance.rootViewController
        instance.window?.makeKeyAndVisible()

        if User.isLoggedIn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                (UIApplication.shared.delegate as? AppDelegate)?.observeChannels()
            }
        }
    }
    
    static func makeRootViewController(_ controller: UIViewController) {
        guard let instance = UIApplication.shared.delegate as? AppDelegate else { return }
        instance.window = UIWindow(frame: UIScreen.main.bounds)
        instance.window?.rootViewController = controller
        instance.window?.makeKeyAndVisible()
    }
}

