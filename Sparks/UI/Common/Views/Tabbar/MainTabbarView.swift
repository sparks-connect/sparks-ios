//
//  MainTabbarView.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

enum MainTabbarViewState: Int {
    case conversations = 0
    case profile = 1
}

protocol MainTabbarViewDelegate: AnyObject {
    func didTap(at item: MainTabbarViewState)
    func didTapOnAction()
}

class MainTabbarView: NibView {
    
    @IBOutlet private weak var stackView: UIStackView!
    
    var currentState: MainTabbarViewState = .conversations {
        didSet {
            configureItems(currentState.rawValue)
        }
    }
    
    weak var delegate: MainTabbarViewDelegate?
    
    override func configure() {
        self.stackView.subviews.forEach({
            guard let item = $0 as? MainTabbarButton else { return }
            item.addTarget(self, action: #selector(didTap(button:)), for: .touchUpInside)
        })
        configureItems(0)
    }
    
    private func configureItems(_ index: Int) {
        self.stackView.subviews.forEach({
            guard let item = $0 as? MainTabbarButton else { return }
            item.isSelected = item.tag == index
        })
    }
    
    func move2(index: Int) {
        self.currentState = MainTabbarViewState.init(rawValue: index) ?? .profile
        self.delegate?.didTap(at: self.currentState)
    }
    
    @objc private func didTap(button: MainTabbarButton) {
        move2(index: button.tag)
    }
    
    
    @IBAction func didTapActionButton(_ sender: Any) {
        delegate?.didTapOnAction()
    }
    
    
}

class MainTabbarButton: UIButton {
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                self.tintColor = UIColor.white
            } else {
                self.tintColor = UIColor.init(hex: "#433C4E")
            }
        }
    }
}
