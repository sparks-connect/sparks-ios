//
//  Int+Ext.swift
//  Sparks
//
//  Created by Nika Samadashvili on 4/9/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

extension Int {
    //  If less then 1000 meter writes m, otherwise devides 1000 and appends "km"
    func toPresentableDistance()->String {
        if self < 1000{
            return String(self).appending(" m")
        }else {
            return String(self/1000).appending(" km")
        }
    }
    
    
    
}

