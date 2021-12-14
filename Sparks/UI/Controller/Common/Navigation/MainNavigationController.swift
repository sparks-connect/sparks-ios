//
//  MainNavigationController.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit

class MainNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override var childForStatusBarStyle: UIViewController? {
        return viewControllers.last
    }
    
   static var mainTabBarController = MainTabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = UIColor.white
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.titleTextAttributes = [
            .font: Font.bold.uiFont(ofSize: 16),
            .foregroundColor: UIColor.white
        ]
        
        let backArrow = Image.back.uiImage
        navigationBar.backIndicatorImage = backArrow
        navigationBar.backIndicatorTransitionMaskImage = backArrow
        view.backgroundColor = Color.background.uiColor
    }
    
    // MARK: - Override back button
        
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil) //use this to remove back button "back" text from any VC that it will show
    }
    
    // MARK: - Dismiss Helpers
    
    func dismissAllAndGoBackToRootVC(animated: Bool, completion: (() -> Void)? = nil) {
        popToRootViewController(animated: animated && presentedViewController == nil)
        if presentedViewController != nil {
            dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    func dismissAllAndGoBackTo(viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        popToViewController(viewController, animated: animated && presentedViewController == nil)
        if presentedViewController != nil {
            dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    func move2(index:Int){
        MainNavigationController.mainTabBarController.move2(index: index)
    }
}

extension MainNavigationController {
    static func createModule() -> MainNavigationController {
        return MainNavigationController(rootViewController: self.mainTabBarController)
    }
}
