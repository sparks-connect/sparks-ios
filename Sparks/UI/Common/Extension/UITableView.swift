//
//  UITableView.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 4/23/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

extension UITableView {
    
    func updateSection(_ section: Int, with animation: UITableView.RowAnimation, deletions: [Int], insertions: [Int], modifications: [Int]) {
        let indexDeletions = deletions.map {IndexPath(row: $0, section: section)}
        let indexInsertions = insertions.map {IndexPath(row: $0, section: section)}
        let indexModifications = modifications.map {IndexPath(row: $0, section: section)}
        self.update(with: animation, section: section, deletions: indexDeletions, insertions: indexInsertions, modifications: indexModifications)
    }
    
    func update(with animation: UITableView.RowAnimation, section: Int, deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath]) {
        if deletions.count > 0 || insertions.count > 0 || modifications.count > 0 {
            
            // According to apple documentation:
            // Use the performBatchUpdates(_:completion:) method instead of this one whenever possible.
            // https://developer.apple.com/documentation/uikit/uitableview/1614908-beginupdates
            
            self.performBatchUpdates({
            
                if deletions.count > 0 {
                    self.deleteRows(at: deletions, with: animation)
                }
                if insertions.count > 0 {
                    self.insertRows(at: insertions, with: animation)
                }
                
                if modifications.count > 0 {
                    self.reloadRows(at: modifications, with: animation)
                }
                
            }) { (finished) in
                if finished {
                    if insertions.count > 0 || deletions.count > 0 {
                        // Content size changes aren't immediate. Set a delay.
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                            self.flashScrollIndicators()
                        }
                    }
                }
            }
        }
    }
    
    func scrollToBottom(animated: Bool = true) {
        // Content size changes aren't immediate. Set a delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            if self.contentSize.height > self.frame.size.height {
                let offset = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
                self.setContentOffset(offset, animated: animated)
            }
        }
    }
    
    func isRowPresentInTableView(indexPath: IndexPath) -> Bool{
        if indexPath.section < self.numberOfSections {
            if indexPath.row < self.numberOfRows(inSection: indexPath.section) {
                return true
            }
        }
        return false
    }
    
}
