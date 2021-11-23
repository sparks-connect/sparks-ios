//
//  CardBottomTitleView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class CardBottomTitleViewCfg: CardContentBaseViewCfg {
    var title: String?
    
    init(title: String? = nil) {
        self.title = title
    }    
}

class CardBottomTitleView: CardContentBaseView {
    override func setup(with config: CardContentBaseViewCfg?) {
        
    }
}
