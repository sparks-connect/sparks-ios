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
    
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.addTarget(self, action: #selector(back), for: .touchUpInside)
        return btn
    }()

    private let titeLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 32, weight:.bold)
        view.numberOfLines = 0
        view.textAlignment = .center
        view.textColor = .white
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.text = "Tell us where you are"
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
        view.text = "We need your approximate location to help you to discover the people who travels in your region."
        //view.text = "\(Consts.App.name) only works when you have location services enabled. To receive spark messages more accurately, we suggest you to set location permission to 'Always' in your phone settings."
        return view
    }()
    
    private lazy var welcomeImg: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "walkthrough")
        return imgView
    }()
    
    private lazy var allowButton: PrimaryButton = {
        let view = PrimaryButton()
        view.setTitle("Allow", for: .normal)
        view.addTarget(self, action: #selector(allowClicked), for: .touchUpInside)
        view.layer.cornerRadius = 32
        return view
    }()
    
    private lazy var manualButton: UIButton = {
        let view = UIButton()
        view.setTitle("Enter manually", for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.font(for: 14, style: .regular)
        view.addTarget(self, action: #selector(manualClicked), for: .touchUpInside)
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
        
        view.addSubview(backBtn)
        view.addSubview(welcomeImg)
        view.addSubview(titeLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(allowButton)
        view.addSubview(manualButton)
        
        backBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(64)
        }

        titeLabel.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.left.equalTo(32)
            $0.right.equalTo(-32)
        }
        
        descriptionLabel.snp.makeConstraints{
            $0.top.equalTo(titeLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(64)
        }
        
        welcomeImg.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(0.5)
        }
        
        manualButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.left.equalToSuperview().inset(24)
            $0.right.equalToSuperview().inset(24)
            $0.height.equalTo(32)
        }
        
        allowButton.snp.makeConstraints {
            $0.bottom.equalTo(manualButton.snp.top).offset(-16)
            $0.left.equalToSuperview().inset(24)
            $0.right.equalToSuperview().inset(24)
            $0.height.equalTo(64)
        }
    }
    
    @objc private func authorizationChanged(notification: Notification) {
        main {
            if LocationManager.sharedInstance.isAuthorizationOk() {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func allowClicked() {
        LocationManager.sharedInstance.requestAuthorization()
    }
    
    @objc private func manualClicked() {
        let controller = PlacesController()
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }

}

extension LocationEnableController: Place {
    func getLocation(info: PlaceInfo) {
        LocationManager.sharedInstance.delegate?.didUpdateTo(info.coordinates?.latitude ?? 0.0, info.coordinates?.longitude ?? 0.0)
        main {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
