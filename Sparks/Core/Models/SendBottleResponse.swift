//
//  SendBottleResponse.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 3/19/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

struct SendBottleResponse: Codable {
    
    let channelId: String?
    private let errorCode: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.channelId = try? container.decode(String?.self, forKey: .channelId)
        self.errorCode = try? container.decode(Int?.self, forKey: .errorCode)
    }
    
    var error: Error? {
        guard let code = errorCode else { return nil }
        return CIError(rawValue: code)
    }
    
    private enum CodingKeys: String, CodingKey {
        case channelId, errorCode
    }
}
