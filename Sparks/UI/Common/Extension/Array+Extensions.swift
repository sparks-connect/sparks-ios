//
//  Array+Extensions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//


import UIKit

extension Array {
    
    mutating func removeObject<T>(_ obj: T) where T : Equatable {
        self = self.filter {$0 as? T != obj}
    }
    
}

extension Array where Element == String {
   
    func compactList(displayCount: Int) -> String {
        if self.count <= displayCount {
            return self.joined(separator: ", ")
        } else {
            let string = self[0..<displayCount].joined(separator: ", ")
            return "\(string) +\(self.count - displayCount) more"
        }
    }
    
    func compactList(forWidth width: CGFloat, font: UIFont) -> String {
        var compactList = self.compactList(displayCount: 1)
        for displayCount in 2...10 {
            let newCompactList = self.compactList(displayCount: displayCount)
            let stringSize = (newCompactList as NSString).size(withAttributes: [.font: font])
            if stringSize.width >= width {
                return compactList
            } else {
                compactList = newCompactList
            }
        }
        return compactList
    }
    
}

extension Array where Element == String? {
    
    func joined(separator: String) -> String {
        return self.stripEmptyStrings().joined(separator: separator)
    }
    
    func stripEmptyStrings() -> [String] {
        return self.compactMap { $0.trimWhitespace().isEmpty ? nil : $0 }
    }
    
    func compactList(displayCount: Int) -> String {
        return self.stripEmptyStrings().compactList(displayCount: displayCount)
    }
    
    func compactList(forWidth width: CGFloat, font: UIFont) -> String {
        return self.stripEmptyStrings().compactList(forWidth: width, font: font)
    }
    
}
