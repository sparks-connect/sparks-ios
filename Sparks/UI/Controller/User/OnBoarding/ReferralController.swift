//
//  ReferralController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 10/25/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit
import SDWebImage


class ReferralController: BasePopupController {
    
    private let photoView: CircleImageView = {
        let view = CircleImageView()
        view.backgroundColor = .white
        view.borderWidth = 0
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.textColor = .white
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = "Invited from "
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = Color.fadedPurple.uiColor
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = "Your message has been delivered to a random person"
        return view
    }()
    
    private let doneButton: LoadingButton = {
        let view = LoadingButton()
        view.setTitle("Got it", for: .normal)
        view.borderWidth = 0
      
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(0, forState: .highlighted)
        view.setBackgroundColor(Color.purple.uiColor, forState: .normal)
        view.setBackgroundColor(Color.purple.uiColor.withAlphaComponent(0.7), forState: .highlighted)
        view.setTintColor(.lightGray, forState: .highlighted)
        return view
    }()
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.popupView.backgroundColor = Color.background.uiColor
        self.doneButton.addTarget(self, action: #selector(didTapOnDone), for: .touchUpInside)
        layout()
    }
    
    convenience init(photoURL: String?, firstName: String){
        self.init()
        self.photoView.setImageFromUrl(photoURL, placeholderImg: Image.profile.uiImage)
        titleLabel.text = "Invited from \(firstName)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func layout(){
        self.popupView.addSubview(photoView)
        photoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(90)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(95)
        }
        
        self.popupView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(photoView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(48)
            $0.centerX.equalToSuperview()
        }
        
        self.popupView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(48)
            $0.centerX.equalToSuperview()
        }
        
        self.popupView.addSubview(doneButton)
        doneButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(48)
            $0.left.right.equalToSuperview().inset(48)
            $0.height.equalTo(60)
        }
        
    }
    
    @objc private func didTapOnDone(){
        self.dismiss(animated: false, completion: nil)
    }
    
}
