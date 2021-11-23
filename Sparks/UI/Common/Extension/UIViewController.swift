//
//  UIViewController.swift
//  Sparks
//
//  Created by George Vashakidze on 6/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

extension UIViewController {
    func showActionSheetWith(actions: [UIAlertAction], title: String) {
        if actions.count > 0 {
            main {
                let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
                actions.forEach({ actionSheet.addAction($0) })
                actionSheet.modalTransitionStyle = .crossDissolve
                actionSheet.modalPresentationStyle = .overFullScreen
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
}
