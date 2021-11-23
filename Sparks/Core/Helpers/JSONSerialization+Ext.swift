//
//  JSONSerialization.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 3/6/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

extension JSONSerialization {
    static func jsonObj2Str(_ jsonObj: Any) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }

    static func jsonStr2Obj(_ jsonStr: String) -> Any? {
        let data = jsonStr.data(using: .utf8)!
        return try? JSONSerialization.jsonObject(with: data, options : .allowFragments)
    }

    static func str2Dictionary(_ jsonStr: String) -> [String: AnyHashable]? {
        return jsonStr2Obj(jsonStr) as? [String: AnyHashable]
    }
}
