//
//  CardContentBuilder.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

enum CardTopContentType: String, Decodable {
    case titleViewWithTags
    case timerView
}

enum CardBottomContentType: String, Decodable {
    case userView
    case adView
    case titleView
}

class CardContentBuilder {
    
    fileprivate var topView: CardContentBaseView?
    fileprivate var bottomView: CardContentBaseView?
   
    static func builder() -> CardContentBuilder {
        return CardContentBuilder()
    }
    
    func setTopView(with topType: CardTopContentType) -> CardContentBuilder {
        switch topType {
        case .titleViewWithTags:
            topView = CardTopTitleViewWithTags()
        case .timerView:
            topView = CardTopTimerView()
        }
        return self
    }
    
    func setBottomView(with bottomType: CardBottomContentType) -> CardContentBuilder {
        switch bottomType {
        case .titleView:
            bottomView = CardBottomTitleView()
        case .adView:
            bottomView = CardBottomAdView()
        case .userView:
            bottomView = CardBottomUserView()
        }
        return self
    }
    
    func setTopViewObject(with topViewObject: CardContentBaseViewCfg) -> CardContentBuilder {
        topView?.setup(with: topViewObject)
        return self
    }
    
    func setBottomViewObject(with bottomViewObject: CardContentBaseViewCfg) -> CardContentBuilder {
        bottomView?.setup(with: bottomViewObject)
        return self
    }
    
    func build() -> CardView {
        let cardView = CardView()
        cardView.topContent = topView
        cardView.bottomContent = bottomView
        return cardView
    }
}
