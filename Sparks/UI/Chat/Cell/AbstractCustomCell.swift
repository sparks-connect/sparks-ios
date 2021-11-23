//
//  AbstractCustomCell.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import MessageKit

protocol AbstractCustomCellProtocol : class {
    func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView)
}

open class AbstractCustomCell: UICollectionViewCell, AbstractCustomCellProtocol {
    
     func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {}
    
   public override init(frame: CGRect) {
          super.init(frame: frame)
    }
    
   public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
