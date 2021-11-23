//
//  Security.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 10/3/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

/*
import Foundation
import RNCryptor

class Security {
    
    private static let SECRET = "37923890^%q23099879"
    
    static func encrypt(str: String) -> String? {
        guard let data = str.data(using: .utf8) else { return nil }
        let ciphertext = RNCryptor.encrypt(data: data, withPassword: SECRET)
        return ciphertext.base64EncodedString()
    }

    static func decrypt(str: String) -> String? {
        // Decryption
        do {
            guard let data = Data(base64Encoded: str) else { return nil }
            let originalData = try RNCryptor.decrypt(data: data, withPassword: SECRET)
            guard let text = String(data: originalData, encoding: .utf8) else { return nil }
            
            return text
        } catch {
            debugPrint("Failed to decrypt - error:  \(error)")
        }
        
        return nil
    }
}
*/
