//
//  CardView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

fileprivate struct Sizes {
    static let containerBorderRadius: CGFloat = 10.0
}

final class CardView: NibView {
    
    @IBOutlet private weak var contentContainerView: UIView!
    @IBOutlet private weak var behindViewFirst: UIView!
    @IBOutlet private weak var behindViewSecond: UIView!
    @IBOutlet private weak var topViewContainer: UIView!
    @IBOutlet private weak var bottomViewContainer: UIView!
    
    var topContent: CardContentBaseView? {
        didSet {
            self.topViewContainer.subviews.forEach({
                $0.removeFromSuperview()
            })
            if let view = self.topContent {
                view.addToContainer(
                    view: self.topViewContainer,
                    attachToBottom: true
                )
            }
        }
    }
    
    var bottomContent: CardContentBaseView? {
        didSet {
            self.bottomViewContainer.subviews.forEach({
                $0.removeFromSuperview()
            })
            if let view = self.bottomContent {
                view.addToContainer(
                    view: self.bottomViewContainer,
                    attachToBottom: true
                )
            }            
        }
    }
    
    override func configure() {
        self.configureLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureCorners()
    }
    
    private func configureCorners() {
        self.contentContainerView.layer.cornerRadius = Sizes.containerBorderRadius
        self.behindViewFirst.layer.cornerRadius = Sizes.containerBorderRadius
        self.behindViewSecond.layer.cornerRadius = Sizes.containerBorderRadius
    }
    
    private func configureLayout() {
        self.contentContainerView.clipsToBounds = true
        self.behindViewFirst.clipsToBounds = true
        self.behindViewSecond.clipsToBounds = true
    }
}
