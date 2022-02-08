//
//  OnboardingPageBaseController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/19/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

protocol PageSize: AnyObject{
    func updateHeight(height: CGFloat)
    func create()
    func setTitle(title: String)
}

class PageBaseController: BaseController {
    weak var delegate: PageSize?
    var pageViewController : BasePageViewController?
    var parameters: [String: Any]? {
        didSet {
            self.didUpdateParameters()
        }
    }
    
    override func configure() {
        super.configure()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func didUpdateParameters() {
        // Override in subclasses
    }
}
