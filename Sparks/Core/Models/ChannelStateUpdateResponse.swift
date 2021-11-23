//
//  ChannelStateUpdateResponse.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 6/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

class ChannelStateUpdateResponse: Codable {
    let success: Bool
    private let errorCode: Int?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.errorCode = try? container.decode(Int?.self, forKey: .errorCode)
    }
    
    var error: Error? {
        guard let code = errorCode else { return nil }
        return CIError(rawValue: code)
    }
    
    private enum CodingKeys: String, CodingKey {
        case success, errorCode
    }
}
