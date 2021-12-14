//
//  CardSwiperCell.swift
//  Sparks
//
//  Created by George Vashakidze on 4/15/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import VerticalCardSwiper

final class CardSwiperCell: CardCell {
    
    private var cardView: CardView!
    
    func configure(channel: Channel) {
        let cardView = buildView(channel: channel)
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        cardView.addToContainer(view: contentView, insets: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0))
    }
    
    private func buildView(channel: Channel) -> CardView {
        let builder = CardContentBuilder.builder()
        _ = builder
            .setTopView(with: .titleViewWithTags)
            .setTopViewObject(with:
                CardTopTitleViewWithTagsCfg(
                    id: channel.uid, createDate: channel.createdAt.toDate, title: channel.initialMessage, tags: []
            ))
            .setBottomView(with: .userView)
            .setBottomViewObject(with: CardBottomUserViewCfg(channel: channel))
        return builder.build()
    }
}
