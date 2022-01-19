//
//  JSONDecoder+Ext.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/13/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

extension JSONDecoder {
    static func decode<T>(_ type: T.Type, from jsonObj: Any) -> T? where T : Decodable {
        guard JSONSerialization.isValidJSONObject(jsonObj),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj)
        else { return nil }
        do {
            let object = try JSONDecoder().decode(type, from: jsonData)
            return object
        } catch let e {
            print("DECODING ERROR FOR TYPE '\(T.self)': \(e)")
            return nil
        }
    }
}
