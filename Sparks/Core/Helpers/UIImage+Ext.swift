//
//  UIImage+Ext.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 6/13/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func compressedImage(url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) else { return nil }
        
        return image
    }

    class func compressedData(url: URL, compresstionQuality: CGFloat = 0.1) -> Data? {
        return compressedImage(url: url)?.jpegData(compressionQuality: compresstionQuality)
    }
    
    var compressed: Data? {
        return self.jpegData(compressionQuality: 0.5)
    }
}
