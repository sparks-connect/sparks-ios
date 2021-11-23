//
//  MessageSizeCalculator.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import MessageKit

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if case .custom(let body) = message.kind {
            
            guard let body = body as? [String: Any]
                else { return DefaultMessageSizeCalculator(layout: self) }
            
            if let _customMessageType = body[Consts.PubNub.kMessageBodyRequestType] as? String,
                let customMessageType = Message.RequestType.init(rawValue: _customMessageType) {
                
                switch customMessageType {
                case .shareRequested:
                    return  message.sender.senderId == User.current?.uid ?
                        CurrentUserRequestMessageSizeCalculator(layout: self) : RecipientRequestMessageSizeCalculator(layout: self)
                case .shareRejected:
                    return  message.sender.senderId == User.current?.uid ?
                        CurrentUserDeclineMessageSizeCalculator(layout: self) : RecipientDeclineMessageSizeCalculator(layout: self)
                case .shareAccepted:
                    return AcceptMessageSizeCalculator(layout: self)
                }
            } else {
                return DefaultMessageSizeCalculator(layout: self)
            }
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
    
}
open class DefaultMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
}

open class CurrentUserRequestMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 300, height: 60)
    }
}

open class RecipientRequestMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 300, height: 60)
    }
}

open class AcceptMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 300, height: 110)
    }
}

open class CurrentUserDeclineMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 300, height: 60)
    }
}

open class RecipientDeclineMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 300, height: 70)
    }
}

