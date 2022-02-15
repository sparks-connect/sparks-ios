//
//  TripPreviewController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 04/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripPreviewController: TripBaseController {
    
    let presenter = TripPreviewPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override var parameters: [String : Any]?{
        didSet {
            self.presenter.datasource = parameters?["preview"] as? [PreviewModel]
        }
    }
   
    private lazy var preview : Preview<TripPreviewPresenter> = {
        let view = Preview(presenter: self.presenter)
        return view
    }()
    
    private let minSize: CGFloat = 76.0
    
    override var titleText: String {
        return "Preview your trip"
    }
    
    override var buttonText: String {
        return "Create"
    }
    
    override var buttonColor: UIColor {
        return Color.green.uiColor
    }

    override func configure() {
        super.configure()
        self.delegate?.setTitle(title: "Create Trip")
        self.view.addSubview(preview)
        preview.snp.makeConstraints { make in
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.top.equalTo(self.titeLabel.snp.bottom).offset(24)
            make.bottom.equalTo(self.nextButton.snp.top).offset(-24)
        }
    }
    
    override func didAppear() {
        super.didAppear()
        main {
            if self.preview.height > self.minSize {
                self.delegate?.updateHeight(height:self.preview.height - self.minSize)
            }
        }
    }
    
    override func nextClicked() {
        self.nextButton.startAnimatingLoader()
        self.delegate?.create(completion:{ isLoaded in
            if isLoaded{
                self.nextButton.stopAnimatingLoader()
            }
        })
    }
    
}
