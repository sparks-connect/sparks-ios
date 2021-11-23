//
//  MessageCollectionView.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/13/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import MessageKit

extension MessagesCollectionView {
    
    
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
                      self.deleteItems(at: deletions)
                  }
                  if insertions.count > 0 {
                      self.insertItems(at: insertions)
                  }
                  
                  if modifications.count > 0 {
                      self.reloadItems(at: modifications)
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
    
}
