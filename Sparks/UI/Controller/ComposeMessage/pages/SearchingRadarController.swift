//
//  SearchingRadarController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 11/9/20.
//  Copyright © 2020 AppWork. All rights reserved.
//


import UIKit
import SnapKit
import MapKit

class SearchingRadarController: PageBaseController {
    
    //MARK: properties
    private let presenter = NewMessagePresenter()
    private let locationManager = CLLocationManager()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private struct Constants {
        static let doneButtonTitle: String = "Done"
        static let controlleTitle: String =  "Compose Message"
        static let messageSentTitle: String = "Sending Sparks"
        static let messageSentDesc: String = "Searching recipient \n for your message"
    }
    
    private let headerView: MainHeaderView = {
        let view = MainHeaderView()
        view.title = Constants.controlleTitle
        view.image = Image.close.uiImage
        return view
    }()
    
    private let doneButton : LoadingButton = {
        let view = LoadingButton()
        view.setBackgroundColor(Color.lightBackground.uiColor, forState: .normal)
        view.clipsToBounds = true
        view.setTitle(Constants.doneButtonTitle, for: .normal)
        view.setBorderWidth(0, forState: .normal)
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let mapView: MKMapView = {
        let view = MKMapView()
        let currentLocation = CLLocationCoordinate2D()
        let viewRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 400, longitudinalMeters: 400)
        view.setRegion(viewRegion, animated: false)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let circularGradientView: CircularGradientView = {
        let view = CircularGradientView()
        view.fadedBackgroudColor = Color.background.uiColor
        return view
    }()
    
    private let radarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let radarLayer: RadarView = {
        let view = RadarView()
        view.numPulse = 10
        view.speed = 0.2
        view.radius = 200
        view.instanceColor = Color.fadedPurple.cgColor
        return view
    }()
    
    private let profileImageView: CircleImageView = {
        let view = CircleImageView()
        view.image = #imageLiteral(resourceName: "ic_settings_refferal_link")
        return view
    }()
    
    private let titleLabel: Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 32)
        view.textColor = .white
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = Constants.messageSentTitle
        return view
    }()
    
    private let descriptionLabel: Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = Color.fadedPurple.uiColor
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = Constants.messageSentDesc
        return view
    }()
    
    private var text: String {
        return self.parameters?["text"] as? String ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layout()
        doneButton.addTarget(self, action: #selector(didPressDoneBtn), for: .touchUpInside)
        headerView.delegate = self
        manageRadar()
        
        if let profileImageStr = User.current?.photoUrl,
           let profileImageUrl = URL(string: profileImageStr) {
            profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: #imageLiteral(resourceName: "profile"))
        }
        profileImageView.layer.zPosition = 1
        
        self.presenter.sendRequestwith(text: text)
    }
    
    private func manageRadar(){
        self.view.addSubview(radarContainer)
        radarContainer.center = self.view.center
        radarContainer.layer.addSublayer(radarLayer)
        radarLayer.start()
    }
    
    private func layout(){
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints({
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(60)
            $0.bottom.equalTo(self.view.safeAreaInsets.bottom).inset(24)
        })
        
        view.addSubview(circularGradientView)
        circularGradientView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalToSuperview()
            $0.right.left.equalToSuperview()
        }
        
        view.addSubview(radarContainer)
        radarContainer.snp.makeConstraints {
            $0.width.height.equalTo(1)
            $0.centerY.centerX.equalToSuperview()
        }
        
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.center.equalTo(radarContainer.snp.center)
            $0.height.width.equalTo(32)
        }
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(60)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(55)
            $0.bottom.equalToSuperview().inset(140)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).inset(-20)
            $0.left.right.equalToSuperview().inset(55)
        }
    }
    
    @objc private func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func didPressDoneBtn(){
        dismissAction()
    }
    
}


extension SearchingRadarController: MainHeaderViewDelegate {
    @objc func didTapOnActionButton() {
        self.dismissAction()
    }
}

extension SearchingRadarController: NewMessageView {
    func didSentMessage() {
        self.pageViewController?.switchTabToNext(parameters: nil)
    }
}
