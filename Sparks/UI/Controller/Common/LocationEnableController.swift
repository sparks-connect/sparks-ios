//
//  LocationEnableController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 8/30/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit
import CoreLocation

class LocationEnableController: BaseController {
    
    private let titeLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 32, weight:.bold)
        view.numberOfLines = 0
        view.textAlignment = .center
        view.textColor = .white
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.text = "Enable Location Services"
        return view
    }()
    
    private let descriptionLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 14, weight:.medium)
        view.textColor = Color.fadedPurple.uiColor
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = "\(Consts.App.name) only works when you have location services enabled. To receive spark messages more accurately, we suggest you to set location permission to 'Always' in your phone settings."
        return view
    }()
    
    private let imageView : UIImageView = {
        let view = UIImageView(image: UIImage(named: "image-location"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let allowButton : CircleLoadingButton = {
        let view = CircleLoadingButton()
        view.setBackgroundColor(Color.green.uiColor, forState: .normal)
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(1, forState: .disabled)
        view.setTitle("Allow", for: .normal)
        view.addTarget(self, action: #selector(allowClicked), for: .touchUpInside)
        return view
    }()
    
    override func configure() {
        super.configure()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authorizationChanged),
                                               name: Consts.Notifications.didChangeLocationPermissions,
                                               object: nil)
        layout()
    }
    
    private func layout() {
        
        view.addSubview(imageView)
        view.addSubview(titeLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(allowButton)
        
        titeLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview().multipliedBy(0.3)
            $0.height.equalTo(100)
            $0.left.equalTo(32)
            $0.right.equalTo(-32)
        }
        
        descriptionLabel.snp.makeConstraints{
            $0.top.equalTo(titeLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(64)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(imageView.snp.height)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
        }
        
        
        allowButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.6)
            $0.height.equalTo(64)
            $0.bottom.equalTo(hasNotchAvailable() ? -42 : 16)
        }
    }
    
    @objc private func authorizationChanged(notification: Notification) {
        main {
            if LocationManager.sharedInstance.isAuthorizationOk() {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func allowClicked() {
        LocationManager.sharedInstance.requestAuthorization()
    }
}
