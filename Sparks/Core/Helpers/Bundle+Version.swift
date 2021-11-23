//
//  Bundle+Version.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/27/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

extension Bundle {
  var releaseVersionNumber: String {
    return infoDictionary?["CFBundleShortVersionString"] as? String ?? "undefined"
  }
  var buildVersionNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String ?? "undefined"
  }
}
