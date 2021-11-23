//
//  String.swift
//  Sparks
//
//  Created by George Vashakidze on 7/19/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

extension String {
    var intValue: Int {
        if let value = Int(self) { return value }
        return 0
    }
}
