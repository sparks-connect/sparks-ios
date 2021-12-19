//
//  TripsPaginatedResponse.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 19.12.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import Foundation

struct TripPaginatedResponse {
    var nextStartDate: Int64
    var trips: [Trip]
}
