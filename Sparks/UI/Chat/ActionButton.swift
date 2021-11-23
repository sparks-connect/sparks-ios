//
//  ActionButton.swift
//  Sparks
//
//  Created by Nika Samadashvili on 7/21/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class ChatActionButton : CircleLoadingButton {
    
    private var buttonState : CurrentUserShareState? {
        didSet {
            activityIndicatorVisible = false
            guard let state = buttonState else {
                isHidden = true
                return
            }
            
            switch state {
            case .notRequested:
                isHidden = false
                isUserInteractionEnabled = true
                titleLabel?.font = .systemFont(ofSize: 12)
                setImage(nil, for: .normal)
                setTitle("unlock", for: .normal)
                setBorderWidth(0, forState: .normal)
                setBackgroundColor(Color.green.uiColor, forState: .normal)
                setTintColor(.white, forState: .normal)
            case .received:
                isHidden = false
                isUserInteractionEnabled = true
                setTitle("" , for: .normal)
                setImage(#imageLiteral(resourceName: "unlockLogo"), for: .normal)
                imageView?.contentMode = .scaleAspectFit
                setBorderWidth(0, forState: .normal)
                setBackgroundColor(.clear, forState: .normal)
            case .pending:
                isHidden = false
                isUserInteractionEnabled = false
                setImage(nil, for: .normal)
                setTitle("pending", for: .normal)
                setBorderWidth(0, forState: .normal)
                setTintColor(.black, forState: .normal)
                setBackgroundColor(.white, forState: .normal)
            case .loadingPending:
                isHidden = false
                isHidden = false
                isUserInteractionEnabled = false
                setImage(nil, for: .normal)
                setTitle("loading", for: .normal)
                setBorderWidth(0, forState: .normal)
                setTintColor(.black, forState: .normal)
                setBackgroundColor(.white, forState: .normal)
            case .shared:
                isHidden = true
            }
            self.tintColorDidChange()
        }
    }
    
    func updateButton(state: CurrentUserShareState?){
        self.buttonState = state
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    convenience init(state: CurrentUserShareState?) {
        self.init()
        self.titleLabel?.font = UIFont.font(for: 12, style: .regular)
        buttonState = state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
