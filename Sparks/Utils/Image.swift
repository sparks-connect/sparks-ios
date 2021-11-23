//
//  Image.swift
//  Sparks
//
//  Created by George Vashakidze on 3/22/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

enum Image: String {
    
    case arrowIcon = "arrowIcon"
    case userSettings = "ic_user_settings"
    case rangeSliderStep = "ic_range_slider_step"
    case rangeSliderStepHighlighted = "ic_range_slider_step_highlited"
    case back = "ic_back"
    case attachFileToChat = "ic_attach_file_to_message"
    case sendMessagePurple = "ic_send_message_up"
    case userPlaceholder = "ic_user_placeholder"
    case approvedUser = "ic_approved_user"
    case locked = "ic_locked"
    case options = "ic_options_three_dots"
    case facebook = "facebookIcon"
    case google = "googleIcon"
    case close = "ic_close"
    case profile = "profile"
    case noImage = "ic_profile_photo_icon"
    case ageRange = "ic_age_range"
    case location = "ic_location"
    
    case sendBallons = "ic_send_ballons"
    
    var uiImage: UIImage {
        return UIImage(imageLiteralResourceName: rawValue)
    }
}

extension UIImage {
    func blurred(filterValue: CGFloat = 10.0, completion: @escaping(UIImage?) -> Void) {
        DispatchQueue.global().async {
            let context = CIContext(options: nil)
            let inputImage = CIImage(image: self)
            let originalOrientation = self.imageOrientation
            let originalScale = self.scale
            
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(inputImage, forKey: kCIInputImageKey)
            filter?.setValue(filterValue, forKey: kCIInputRadiusKey)
            
            guard let oImage = filter?.outputImage, let iContext = inputImage?.extent else {
                completion(nil)
                return
            }
            
            guard let cgImage = context.createCGImage(oImage, from: iContext) else {
                completion(nil)
                return
            }
            completion(UIImage(cgImage: cgImage, scale: originalScale, orientation: originalOrientation))
        }
    }
    
    func addBlurTo() -> UIImage? {
        if let ciImg = CIImage(image: self) {
            ciImg.applyingFilter("CIGaussianBlur")
            return UIImage(ciImage: ciImg)
        }
        return nil
    }
}
