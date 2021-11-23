//
//  CardContentBaseView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class CardContentBaseViewCfg {
    
}

protocol CardContentBaseViewDelegate: class {}

class CardContentBaseView: BaseView {
    
    weak var delegate: CardContentBaseViewDelegate?
    
    func setup(with config: CardContentBaseViewCfg?) {
        
    }
    
}
