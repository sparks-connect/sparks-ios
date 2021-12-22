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

extension UIView {
    func height(constant: CGFloat) {
        setConstraint(value: constant, attribute: .height)
    }
    
    func width(constant: CGFloat) {
        setConstraint(value: constant, attribute: .width)
    }
    
    private func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraints.forEach {
            if $0.firstAttribute == attribute {
                removeConstraint($0)
            }
        }
    }
    
    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        removeConstraint(attribute: attribute)
        let constraint =
        NSLayoutConstraint(item: self,
                           attribute: attribute,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: nil,
                           attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                           multiplier: 1,
                           constant: value)
        self.addConstraint(constraint)
    }
}
