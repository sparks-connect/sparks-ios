//
//  Utils.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/28/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

enum MeasureType {
    case KM
    case MT
}

// MARK: ########### Dispatch Queue ######################
func main(block:@escaping ()->Void) {
    async(block: block)
}

func main(block:@escaping ()->Void, after: TimeInterval) {
    async(block: block, after: after)
}

func background(block:@escaping ()->Void) {
    async(block: block, on: DispatchQueue.global())
}

func background(block:@escaping ()->Void, after: TimeInterval) {
    async(block: block, after: after, on: DispatchQueue.global())
}

private func async(block:@escaping ()->Void, on queue: DispatchQueue = DispatchQueue.main) {
    queue.async(execute: block)
}

private func async(block:@escaping ()->Void, after: TimeInterval, on queue: DispatchQueue = DispatchQueue.main) {
    queue.asyncAfter(deadline: DispatchTime.now() + after, execute: block)
}

func readJsonArrayFromFile<T: Decodable>(file: String) -> [T] {
    guard let url = Bundle.main.url(forResource: file, withExtension: "json") else { return [T]() }
    do {
        let jsonData = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([T].self, from: jsonData)
    } catch {
        print(error)
    }
    return [T]()
}

func distanceDouble(between location1: CLLocation, location2: CLLocation, measureType: MeasureType = .KM) -> Double {
    let distance = location1.distance(from: location2) / (measureType == .KM ? 1000 : 1)
    return distance
}

func distanceStr(between location1: CLLocation, location2: CLLocation) -> String {
    let distance = distanceDouble(between: location1, location2: location2, measureType: .KM)
    return String(format: "%.01f km", distance)
}

//###### UI ##########
func hasNotchAvailable() -> Bool {
    var bottomSafeArea: CGFloat
    
    if #available(iOS 11.0, *) {
        bottomSafeArea = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.view.safeAreaInsets.bottom ?? 0
        return bottomSafeArea > 0
    }
    return false
}

final class FileUtils {
    
    class func openFile(url: URL) -> FileHandle? {
        
        var fileHandle: FileHandle? = nil
        
        // If the file doesn't exist, then create it.
        let path = url.path
        if !FileManager.default.fileExists(atPath: path) {
            
            if !FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) {
                
                debugPrint("(\(#function)) - Failed to create log file '\(url)'.")
            }
        }
        
        do {
            
            // Try to get a file handle on the log file.
            fileHandle = try FileHandle(forUpdating: url)
        }
        catch let error as NSError {
            
            debugPrint("(\(#function)) - Error occurred when writing to log file '\(url)': \(error)")
        }
        
        return fileHandle
    }
    
    class func moveItem(at: URL, to: URL) throws {
        try FileManager.default.moveItem(at: at, to: to)
    }
    
    class func removeItem(at: URL) throws {
        try FileManager.default.removeItem(at: at)
    }
    
    class func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    class func getDocumentsDirectory() -> URL {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Unhandled exception")
        }
        
        return path
    }
    
    class func getCacheDirectory() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last
    }
    
    class func tempURL(for ext: String) -> URL {
        let directory = NSTemporaryDirectory()
        let tmpPath = "\(UUID().uuidString).\(ext)"
        let path = directory.appending(tmpPath)
        return URL(fileURLWithPath: path)
    }
    
    class func createFile(at url: URL, data: Data) -> Bool {
        return FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
    }
    
    class func createDirectoryIfNeeded(at url: URL) {
        if !directoryExists(at: url) {
            try? FileManager.default.createDirectory(atPath: url.path,
                                                     withIntermediateDirectories: false,
                                                     attributes: nil)
        }
    }
    
    class func directoryExists(at url: URL) -> Bool {
        var yes: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &yes)
        return yes.boolValue && exists
    }
    
    class func readFile(at url: URL) -> Data? {
        return FileManager.default.contents(atPath: url.path)
    }
}

extension Date {
    var currentUTCDateStr: String {
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateStyle = .medium
        utcDateFormatter.timeStyle = .medium
        utcDateFormatter.dateFormat = "yyyy-MM-dd"
        // The default timeZone on DateFormatter is the device’s
        // local time zone. Set timeZone to UTC to get UTC time.
        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return utcDateFormatter.string(from: self)
    }
}

extension FileUtils {
    class func addCacheImage(_ image: UIImage) -> URL? {
        guard let url = URL(string: getCacheDirectory()?.absoluteString ?? "" + "/images"),
                let data = image.compressed else {
            return nil
        }
        if createFile(at: url, data: data) {
            return url
        }
        return nil
    }
}
