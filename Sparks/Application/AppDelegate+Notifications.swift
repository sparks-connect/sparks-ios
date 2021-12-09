//
//  AppDelegate+Notifications.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 8/25/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import FirebaseMessaging

typealias DeviceTokenHandler = (_ deviceToken:String?, _ error:Error?) -> Void

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate
{
    
    //MARK:- SetupNotification Method While initialize
    func setupNotification(_ application: UIApplication, completion:@escaping DeviceTokenHandler) {
        //UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    //MARK:- ID Register Notification Device token
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        if let token = Messaging.messaging().fcmToken {
            print("FCM Token: \(token)")
            Service.auth.updateToken(token) { (_) in }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //opened from a push notification when the app was on background
        guard let __type = userInfo["type"] as? String,
                let _type = Int(__type),
                    let type = NotificationType(rawValue: _type) else { return }
        
        
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
        
        if UIApplication.shared.applicationState != .active {
            switch type {
            case .spark:
                MainNavigationController.mainTabBarController.move2(index: 0)
            case .message, .unlock:
                if let channelID = userInfo["channelId"] as? String {
                    MainNavigationController.mainTabBarController.move2(index: 1)
                    MainNavigationController.mainTabBarController.presentChannel(withID: channelID)
                }
            }
        }
    }
}

