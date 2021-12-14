//
//  BasePageViewController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 11/23/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import Foundation

protocol BasePageViewController {
    func switchTabToNext(parameters: [String: Any]?)
    func didTapAtCloseButton()
    func switchTabToPrevious()
    
}
