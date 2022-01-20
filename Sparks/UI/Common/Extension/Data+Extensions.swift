//
//  Data+Extensions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    
    /// Saves the data in the temp folder.
    ///
    /// - Parameter withExtension: The extension of the data
    /// - Returns: The url of where the data is saved
    func saveInTempFolder(withExtension: String) -> URL? {
        let uuid = UUID().uuidString
        let path = NSTemporaryDirectory() + "/\(uuid).\(withExtension)"
        let url = URL(fileURLWithPath: path)
        do {
            try self.write(to: url, options: [.atomic])
            return url
        }
        catch {
            return nil
        }
    }
    
    var sha512: Data? {
        return withUnsafeBytes { message in
            var digest = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
            let didSucceed: Bool = digest.withUnsafeMutableBytes { digest in
                guard
                    let message = message.baseAddress,
                    let digest = digest
                        .bindMemory(to: UInt8.self)
                        .baseAddress
                    else { return false }
                CC_SHA512(message, CC_LONG(count), digest)
                return true
            }
            return didSucceed ? digest : nil
        }
    }
    
    var hexEncodedString: String {
        // Based on https://stackoverflow.com/a/40089462/293215
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

