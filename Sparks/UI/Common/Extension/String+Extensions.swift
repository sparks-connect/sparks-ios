//
//  String+Extensions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//
import Foundation
import UIKit

extension String {
    
    func truncated(to maxCount: Int, ellipsis: String) -> String {
        return count <= maxCount
            ? self
            : prefix(maxCount - 1) + ellipsis
    }
    
    /// Returns the SHA5 version of the string.
    func sha5Hash() -> String? {
        return data(using: .utf8)?.sha512?.hexEncodedString
    }
    
    /// Returns copy of the string with whitespace and new line characters trimmed off the ends.
    func trimWhitespace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// Returns the string with converted HTML character references.
    func removeCharacterEntityReferences() -> String {
        var returnString = self.replacingOccurrences(of: "&amp;", with: "&")
        returnString = returnString.replacingOccurrences(of: "&nbsp;", with: " ")
        return returnString
    }
    
    /// Returns whether or not the string could be a valid email.
    func couldBeValidEmail() -> Bool {
        // Contains one '@' and it isn't the first character.
        let atString = "@"
        if let atRange = self.range(of: atString), let regex = try? NSRegularExpression(pattern: atString, options: .caseInsensitive) {
            let numberOfMatches = regex.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count))
            return atRange.lowerBound != self.startIndex && atRange.upperBound != self.endIndex && numberOfMatches == 1
        }
        return false
    }
    
    /// Returns whether or not the string is a valid routing number per ABA standard.
    func couldBeValidRoutingNumber() -> Bool {
        if self.count != 9 || !self.isInteger {
            return false
        }
        
        // http://answers.google.com/answers/threadview/id/43619.html
        var n = 0
        let charArray = self.compactMap { Int(String($0)) }
        for i in stride(from: 0, to: self.count, by: 3) {
            let digit1 = Int(charArray[i])
            n += digit1 * 3
            let digit2 = Int(charArray[i + 1])
            n += digit2 * 7
            let digit3 = Int(charArray[i + 2])
            n += digit3
        }
        
        // If the resulting sum is an even multiple of ten (but not zero),
        // the aba routing number is good.
        return n != 0 && n % 10 == 0
    }
    
    /// Returns whether or not the string is a valid password.
    func isValidForOldLogin() -> Bool {
        return self.count >= 6
    }
    
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    /// Returns whether or not the string is a valid account number.
    func couldBeValidAccountNumber() -> Bool {
        if self.count >= 4 && self.count <= 17 {
            return self.isInteger
        }
        return false
    }
    
    /// Returns the string converted to asterisks after the first four characters.
    func obfuscatedString() -> String {
        let beginningString = String(self.prefix(4))
        return beginningString.padding(toLength: self.count, withPad: "*", startingAt: 0)
    }
    
    /// Converts the string to ISO 8601 Date, cuz some can have milliseconds, some not.
    func convertToISO8601Date() -> Date? {
        if let returnString = DateFormatter.defaultDateFormatter.date(from: self) {
            return returnString
        } else if let returnString = DateFormatter.defaultDateOnlyFormatter.date(from: self) {
            return returnString
        }
        return DateFormatter.defaultDateFormatterWithoutMilliseconds.date(from: self)
    }
    
    /// Returns a string that's been pluralized (or not), depending on amount.
    ///
    /// - Parameter amount: The amount of the item in question.
    /// - Returns: The string pluralized, if needed.
    func pluralized(forAmount amount: Int) -> String {
//        let lowercase = self.lowercased()
//        switch lowercase {
//        case "story uploads":
//            return self
//        default:
//            break
//        }
        
        if amount == 1 || amount == -1 {
            return self
        } else {
            return self + "s"
        }
    }
    
    /// NEW analytics events title style.
    func stringForNewAnalyticsEvents() -> String {
        let formattedString = self.lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "_")
        if formattedString.isValidFirebaseString {
            return formattedString
        } else {
            assert(false, "Received invalid Firebase string.")
            return ""
        }
    }
    
    /// Returns an attributed version of the String with specific text formatted to look like a link.
    ///
    /// - Parameter highlightedText: The specific text to format like a link.
    /// - Returns: The attributed string with the formatted string.
    func attributedString(withLink linkText: String) -> NSMutableAttributedString {
        if let swiftRange = self.range(of: linkText) {
            let nsRange = NSRange(swiftRange, in: self)
            let string = NSMutableAttributedString(string: self)
            string.addAttributes([.foregroundColor: UIColor.black], range: nsRange)
            return string
        }
        return NSMutableAttributedString(string: self)
    }
    
    // MARK: Helpers
    
    /// Returns whether or not the string is an integer.
    private var isInteger: Bool {
        let numberCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return !self.isEmpty && self.rangeOfCharacter(from: numberCharacters) == nil
    }
    
    /// Not private due to testing.
    var isValidFirebaseString: Bool {
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert("_")
        return self.count > 0 && CharacterSet.letters.contains(self.first?.unicodeScalars.first ?? "0") && self.rangeOfCharacter(from: allowedCharacters.inverted) == nil && self.count <= 40 && self.containsNoFirebaseReservedPrefixes
    }
    
    var withFirstCharacterUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    private var containsNoFirebaseReservedPrefixes: Bool {
        return !self.hasPrefix("firebase_") && !self.hasPrefix("google_") && !self.hasPrefix("ga_")
    }
    
}

extension Optional where Wrapped: ExpressibleByStringLiteral {
    
    /// Returns whether or not the string is empty or nil.
    var isEmpty: Bool {
        return (self as? String ?? "").isEmpty
    }
    
    /// - Returns: A new string without the whitespace.
    func trimWhitespace() -> String {
        return (self as? String ?? "").trimWhitespace()
    }
    
    //@available(*, deprecated: 10.0, message: "Use stringForNewAnalyticsEvents() instead")
    /// Creates a string version that is specifically for analytics events.
    func stringForAnalyticsEvents() -> String {
        return (self as? String ?? "").lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
}
