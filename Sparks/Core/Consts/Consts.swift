//
//  Consts.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/10/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit


// MARK: ########### Colors ######################

private let MAX_CHANNEL: CGFloat = 255

func color(from hex: String, alpha: CGFloat = 1) -> UIColor {
    let tuple = rgbFromHex(hex)
    return rgba(tuple.0, g: tuple.1, b: tuple.2, a: alpha)
}

func rgbFromHex(_ colorCode: String) -> (CGFloat, CGFloat, CGFloat) {
    let scanner = Scanner(string:colorCode)
    var color:UInt32 = 0;
    scanner.scanHexInt32(&color)

    let mask = 0x000000FF
    let r = CGFloat(Float(Int(color >> 16) & mask))
    let g = CGFloat(Float(Int(color >> 8) & mask))
    let b = CGFloat(Float(Int(color) & mask))
    return (r, g, b)
}


func rgba(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)-> UIColor {
    let newRed = CGFloat(r)/MAX_CHANNEL
    let newGreen = CGFloat(g)/MAX_CHANNEL
    let newBlue = CGFloat(b)/MAX_CHANNEL
    return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: a)
}


struct Consts {
    struct MillisecodsInUnit {
        static let second = 1_000
        static let minute = 60_000
        static let hour   = 3_600_000
    }
    
    struct Notifications {
        static let didChangeUser = Notification.Name("didChangeUser")
        static let connectionChanged = Notification.Name("connectionChanged")
        static let didChangeLocationPermissions = Notification.Name("didChangeLocationPermissions")
        static let didSendSpark = Notification.Name("didSentSpark")
    }

    struct PubNub {
        static let publish = "pub-c-5f8a4432-4495-4f64-9cff-537d8e170744"
        static let subscribe = "sub-c-75be0136-4bf3-11ea-94fd-ea35a5fcc55f"
        static let kMessageBodyLink = "links"
        static let kMessageBodyText = "message"
        static let kMessageBodyLocation = "coordinates"
        static let kMessageBodyRequestType = "requestType"
        static let kMessageBodyType = "type" 
    }

    struct Firebase {
        static let firaStorageBaseUrl = "https://firebasestorage.googleapis.com/v0/b/appwork-f831d.appspot.com/o/users%2F"
        static let apiCall_connectToUser = "connectToUser"
        static let apiCall_channelCreate = "getBottleRecipients"
        static let apiCall_acceptChannel = "acceptChannel"
        static let apiCall_rejectChannel = "rejectChannel"
        static let apiCall_shareChannel = "shareChannel"
        
        static let apiCall_ResponseChannelId = "channelId"
        static let apiCall_ResponseErrorCode = "errorCode"
        
        static let fcmURL = URL(string: "https://fcm.googleapis.com/fcm/send") ?? URL(fileURLWithPath: "")
        static let fcmAPIKey = "AAAAlSfGGVM:APA91bGJ4ksa19GfUCltfj3X6ekfpwJOEV02QU38qP10eBcFUdkYODpFyh5QT6zpBsxAnpOo8jK9JsrbZKdyY8jley8XRYZnLWMRvUMnjr7EzMkalIARW91dZJB-yUcs62d3sF_hWrHO"
    }
    
    struct FirebaseCloudMessaging {
        static let profileUnlockRequestTitle = "Unlock"
        static let newSparkTitle             = "Spark"
        static let sparkBody                 = "New Spark from"
    }
    
    struct Defaults {
        static let kmDistance = 5
        static let otpLength = 6
    }

    struct Device {
        static let messageMetadata = ["platform": "iOS", "OS_version": UIDevice.current.systemVersion, "APP_version": Bundle.main.releaseVersionNumber]
    }

    struct Colors {
        static func getMain() -> UIColor {
            return Colors.ACCENT
        }
        
        static let INK_BLUE = color(from: "150D4C")
        static let ACCENT = color(from: "FAC800")
        static let BACKGROUND = color(from: "2A363B")
        static let LIGHT_GRAY = color(from: "d3d3d3")
        static let GRAY = color(from: "6B6B6B")
    }
    
    public static var screenFactor: CGFloat {
        get {
            return UIScreen.main.bounds.size.width/375
        }
    }

    struct App {
        static let bundleIdentifier = Bundle.main.bundleIdentifier
        static let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Sparks"
    }
}
