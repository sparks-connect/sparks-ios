//
//  Data+Ext.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 6/13/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

extension Data {
    
    var compressedImage: Data? {
        UIImage(data: self)?.jpegData(compressionQuality: 0.1)
    }
    
    var hexString: String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
