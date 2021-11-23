//
//  UnlockRequestController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 4/22/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

protocol UnlockRequestControllerDelegate : AnyObject {
    func didTapAccept()
    func didTapDecline()
}

final class UnlockRequestController: BottomSheetController {
    
    //MARK: properties
    
    weak var delegate : UnlockRequestControllerDelegate?
    
    lazy private var unlockImage : ImageView = {
        let view = ImageView()
        view.image = #imageLiteral(resourceName: "grayUnlockLogo")
        return view
    }()
    
    lazy private var titleLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 22, weight: .light)
        view.text = "Do you want to unlock ?"
        view.textColor = .white
        return view
    }()
    
    lazy private var descriptionLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = "You both will be able to see each others profile information and photos"
        view.textColor = Color.fadedPurple.uiColor
        return view
    }()
    
    lazy private var requestButton: ActionButton = {
        let view = ActionButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Unlock", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = Color.green.uiColor
        view.setBackgroundColor(Color.green.uiColor.withAlphaComponent(0.7), forState: .disabled)
        view.setBackgroundColor(Color.green.uiColor, forState: .normal)
        view.setBorderWidth(0, forState: .disabled)
        view.setBorderWidth(0, forState: .normal)
        return view
    }()
    
    lazy private var cancelButton: Button = {
        let view = Button()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Cancel", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        view.setTitleColor(Color.fadedPurple.uiColor, for: .normal)
        view.setTitleColor(Color.fadedPurple.uiColor.withAlphaComponent(0.7), for: .disabled)
        view.layer.borderWidth = 0
        return view
    }()
    
    
    
    //MARK: public functions
    
    override func loadView() {
        super.loadView()
        configureSubviews()
        
    }
    
    override func configure() {
        super.configure()
       setTintColor(color: Color.lightBackground.uiColor) 
    }
    
    //MARK: private functions
    private func configureSubviews() {
        popupView.addSubview(unlockImage)
        popupView.addSubview(titleLabel)
        popupView.addSubview(descriptionLabel)
        popupView.addSubview(requestButton)
        popupView.addSubview(cancelButton)
        
        unlockImage.snp.makeConstraints({
            $0.top.equalToSuperview().inset(48)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(64)
        })
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(unlockImage.snp.bottom).inset(-30)
            $0.centerX.equalToSuperview()
        })
        
        descriptionLabel.snp.makeConstraints({
            $0.top.equalTo((titleLabel.snp.bottom)).inset(-18)
            $0.left.equalTo(80)
            $0.right.equalTo(-80)
            $0.centerX.equalToSuperview()
        })
        
        cancelButton.snp.makeConstraints {
            $0.bottom.equalTo(popupView.snp.bottom).inset(48)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        requestButton.snp.makeConstraints({
            $0.bottom.equalTo(cancelButton.snp.top).inset(-25)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.width.equalTo(165)
        })
        
        requestButton.addTarget(self, action: #selector(didTapAtRequestButton(_ :)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapAtCancelButton(_ :)), for: .touchUpInside)
    }
    
    
    @objc private func didTapAtRequestButton(_ button: ActionButton) {
        button.startAnimatingLoader()
        self.delegate?.didTapAccept()
        closePopupView()
    }
    
    @objc private func didTapAtCancelButton(_ button: ActionButton) {
        closePopupView()
    }
    
}
