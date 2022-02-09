//
//  TripNameInputController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 27/01/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripNameInputController: TripBaseController {
    
    let presenter = TripNamePresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }

    private lazy var cityLabel: Label = {
        let lbl = Label()
        lbl.textAlignment = .left
        lbl.font =  UIFont.systemFont(ofSize: 20, weight:.light)
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.alpha = 0.4
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.text = "Type city name..."
        lbl.isUserInteractionEnabled = true
        lbl.addTapGesture(target: self, selector: #selector(navigateToPlaces))
        return lbl
    }()
    
    override func configure(){
        super.configure()
        self.view.addSubview(cityLabel)
        cityLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview().offset(-32)
            $0.left.equalTo(32)
            $0.right.equalTo(-32)
        }
    }

    override func reloadView() {
        super.reloadView()
    }
    
    override func didAppear() {
        super.didAppear()
    }
    
    @objc func navigateToPlaces(){
        let places = PlacesController()
        places.delegate = self.presenter
        self.present(places, animated: true, completion: nil)
    }
    
    @objc override func nextClicked(){
        self.pageViewController?.switchTabToNext(parameters: nil)
    }
}

extension TripNameInputController: TripNameView {
    func updateLocation(text: String?) {
        self.cityLabel.text = text
    }
}
