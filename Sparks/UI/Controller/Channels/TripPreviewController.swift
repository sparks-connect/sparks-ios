//
//  TripPreviewController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 04/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripPreviewController: TripBaseController{
    override var titleText: String {
        return "Preview your trip"
    }
    
    override var buttonText: String {
        return "Create"
    }
    
    override var buttonColor: UIColor {
        return Color.green.uiColor
    }
}
