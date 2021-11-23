//
//  Int64+Ext.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 6/15/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

extension Int64 {
    var toDate: Date {
        return Date(milliseconds: self)
    }
}
