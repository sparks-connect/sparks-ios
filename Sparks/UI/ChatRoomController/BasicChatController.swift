
//
//  ChatListController.swift
//  appwork
//
//  Created by Nika Samadashvili on 3/8/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView


/// A base class for the example controllers
class ChatViewController: MessagesViewController  {
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configureMessageCollectionView()
       // configureMessageInputBar()
        loadFirstMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
//        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: navbarCustomHeight)
        
       
         
//        MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
//            .onNewMessage { [weak self] message in
//                self?.insertMessage(message)
//        }
    }
   

    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        MockSocket.shared.disconnect()
//        audioController.stopAnyOngoingPlaying()
    }
    
    func loadFirstMessages() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            let count = UserDefaults.standard.mockMessagesCount()
//            SampleData.shared.getMessages(count: count) { messages in
//                DispatchQueue.main.async {
//                    self.messageList = messages
//                    self.messagesCollectionView.reloadData()
//                    self.messagesCollectionView.scrollToBottom()
//                }
//            }
//        }
    }
    
    @objc
    func loadMoreMessages() {
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//            SampleData.shared.getMessages(count: 20) { messages in
//                DispatchQueue.main.async {
//                    self.messageList.insert(contentsOf: messages, at: 0)
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                    self.refreshControl.endRefreshing()
//                }
//            }
//        }
    }
    
 
    
//    func configureMessageInputBar() {
//
//    }
//
    // MARK: - Helpers
    

    
 
    
  
    
}



// MARK: - MessageLabelDelegate


