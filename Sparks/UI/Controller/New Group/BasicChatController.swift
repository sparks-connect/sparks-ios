//
//  BasicChatController.swift
//  appwork
//
//  Created by Nika Samadashvili on 3/3/20.
//  Copyright © 2020 AppWork. All rights reserved.
////
//
//import UIKit
//import MessageKit
//import InputBarAccessoryView
//
//
// class BasicExampleViewController: ChatViewController{
//      override func configureMessageCollectionView() {
//          super.configureMessageCollectionView()
//          messagesCollectionView.messagesLayoutDelegate = self
//          messagesCollectionView.messagesDisplayDelegate = self
//      //  messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CollectionViewLayout.init )
//              messagesCollectionView.register(MyCustomCell.self)
//      }
////    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////          guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
////              fatalError("Ouch. nil data source for messages")
////          }
////
////          let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
////          if case .custom = message.kind {
////              let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
////              //cell.configure(with: message, at: indexPath, and: messagesCollectionView)
////              return cell
////          }
////          return super.collectionView(collectionView, cellForItemAt: indexPath)
////      }
//    
//  }
//
//
//extension BasicExampleViewController: MessagesDisplayDelegate {
//    
//    // MARK: - Text Messages
//    
//    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        return isFromCurrentSender(message: message) ? .white : .darkText
//    }
//    
//    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
//        switch detector {
//        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
//        default: return MessageLabel.defaultAttributes
//        }
//    }
//    
//    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
//        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
//    }
//    
//    // MARK: - All Messages
//    
////    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
////        return isFromCurrentSender(message: message) ? .black : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
////    }
//    
//    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//        
//        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
//        return .bubbleTail(tail, .curved)
//    }
//    
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
////        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
//        avatarView.set(avatar:Avatar(image: nil, initials: "k.a"))
//    }
//    
//    // MARK: - Location Messages
//    
////    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
////        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
////        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
////        annotationView.image = pinImage
////        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
////        return annotationView
////    }
//    
//    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
//        return { view in
//            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
//            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
//                view.layer.transform = CATransform3DIdentity
//            }, completion: nil)
//        }
//    }
//    
////    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
////        
////        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
////    }
//
//    // MARK: - Audio Messages
//
//    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
//    }
//    
//    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
//     //   audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
//    }
//
//}
//
//// MARK: - MessagesLayoutDelegate
//
//extension BasicExampleViewController: MessagesLayoutDelegate {
//    
//    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 18
//    }
//    
//    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 17
//    }
//    
//    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 20
//    }
//    
//    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 16
//    }
//    
//}
