//
//  TripInfoController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 09/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class TripInfoController: BaseController {
    
    private lazy var imgView: CircleImageView = {
        let img = CircleImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.backgroundColor = .red
        return img
    }()
    
    let datasource = [
        PreviewModel(icon: "icn-loc", text: "Vienna, Austria"),
        PreviewModel(icon: "icn-cal", text: "10 Dec, 2021 - 14 Dec, 2021"),
        PreviewModel(icon: "icn-purpose", text: "Leisure"),
        PreviewModel(icon: "icn-grp", text: "With friends"),
        PreviewModel(icon: "icn-info", text: "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum")
    ]
    
    private lazy var preview: Preview = {
        let view = Preview(data: datasource)
        return view
    }()
    
    private lazy var lblTripInfo: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Trip Information"
        lbl.font = Font.light.uiFont(ofSize: 14)
        lbl.textColor = .white
        return lbl
    }()
    
    private lazy var profileButton: PrimaryButton = {
        let btn = PrimaryButton()
        btn.setTitle("View Profile", for: .normal)
//        btn.addTarget(self, action: #selector(nextClicked), for: .touchUpInside)
        btn.layer.cornerRadius = 22
//        btn.setBackgroundColor(buttonColor, forState: .normal)
        return btn
    }()
    
    private lazy var connectButton: PrimaryButton = {
        let btn = PrimaryButton()
        btn.setTitle("Ask to connect", for: .normal)
        //        btn.addTarget(self, action: #selector(nextClicked), for: .touchUpInside)
        btn.layer.cornerRadius = 22
        btn.setBackgroundColor(Color.green.uiColor, forState: .normal)
        return btn
    }()
        
    private lazy var reportBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Report", for: .normal)
        btn.setTitleColor(Color.fb.uiColor, for: .normal)
        btn.titleLabel?.font = Font.regular.uiFont(ofSize: 14)
        return btn
    }()
        
    override func configure() {
        super.configure()
        layout()
    }
    
    private func layout(){
        self.view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(imgView.snp.width).multipliedBy(1)
        }
        
        self.view.addSubview(lblTripInfo)
        lblTripInfo.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.top.equalTo(imgView.snp.bottom).offset(24)
        }
        
        self.view.addSubview(preview)
        preview.snp.makeConstraints { make in
            make.leading.equalTo(32)
            make.top.equalTo(lblTripInfo.snp.bottom).offset(16)
            make.trailing.equalTo(-32)
            make.height.equalTo(preview.height)
        }
        
        self.view.addSubview(profileButton)
        profileButton.snp.makeConstraints { make in
            make.leading.equalTo(32)
            make.top.equalTo(preview.snp.bottom).offset(32)
            make.trailing.equalTo(-32)
            make.height.equalTo(44)
        }
        
        self.view.addSubview(connectButton)
        connectButton.snp.makeConstraints { make in
            make.leading.equalTo(32)
            make.top.equalTo(profileButton.snp.bottom).offset(16)
            make.trailing.equalTo(-32)
            make.height.equalTo(44)
        }
        
        self.view.addSubview(reportBtn)
        reportBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }

    }
    
    override func didAppear() {
        super.didAppear()
        main {
            self.preview.snp.updateConstraints { make in
                make.height.equalTo(self.preview.height+10)
            }
        }
    }
}

