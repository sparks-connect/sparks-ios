//
//  AppDelegate+URL.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 10/3/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import Foundation
import FirebaseDynamicLinks

class ReferrerUser {
    
    private(set) var uid: String
    private(set) var name: String
    
    var photoUrl: String {
        return "\(Consts.Firebase.firaStorageBaseUrl)\(uid)%2Fprofileimage0.jpg?alt=media"
    }
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
}

extension AppDelegate {
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard let url = userActivity.webpageURL, User.current == nil else { return false }
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
            if let url = dynamiclink?.url {
                if let uid = url.getQueryParameterValue(param: "uid"),
                   let name = url.getQueryParameterValue(param: "name") {
                    
                    MemoryStore.sharedInstance.putValue(uid, forKey: MemoryStore.MemoryKeys.userUid)
                    
                    let user = ReferrerUser(uid: uid, name: name)
                    let referralController = ReferralController(photoURL: user.photoUrl, firstName: user.name)
                    referralController.modalPresentationStyle = .overFullScreen
                    self.topMostViewController?.present(referralController, animated: false, completion: nil)
                }
            }
        }
        
        return handled
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.application(app,
                                open: url,
                                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                annotation: "")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let _ = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            return true
        }
        return false
    }
}
