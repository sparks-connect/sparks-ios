//
//  URL+Extensions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Alamofire

enum URLContentType: Int {
    case gif, image, pdf, video, audio
}

extension URL {
    
    private static let baseDomain = "https://www.sparks.ooo/"
    static let baseSupportDomain = "https://www.sparks.ooo/support"
    
    /// - Returns: URL for Terms of Service
    static func termsOfService() -> URL {
        return self.baseDomain(withPath: "terms/")
    }
    
    /// - Returns: URL for the Privacy Policy
    static func privacyPolicy() -> URL {
        return self.baseDomain(withPath: "privacy/")
    }
    
    static func faq() -> URL {
        return self.baseDomain(withPath: "faq")
    }
    
    /// - Returns: URL for the Support Center
    static func supportCenter() -> URL {
        return URL(string: URL.baseSupportDomain)!
    }
    
    /// - Returns: URL for the App Store
    static func appStore() -> URL {
        return self.init(string: "itms-apps://itunes.apple.com/app/id******")!
    }
    
    static func whatIsMixedMedia() -> URL {
        return self.init(string: "\(URL.baseSupportDomain)hc/en-us/articles/360037943771-What-is-Mixed-Media-")!
    }
    
    /// Get the content type of the URL file based on extension.
    ///
    /// - Returns: The MIME type suggested by the extension.
    func mimeTypeBasedOnExtension() -> String? {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self.pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    /// Returns an enumerated value of the content type based on MIME type.
    /// http://docs.developmentpopularpaysapiv3.apiary.io/#reference/content-submissions/create/create
    ///
    /// - Returns: Enumeration of the content type.
    var contentType: URLContentType? {
        if let mimeType = self.mimeTypeBasedOnExtension() {
            if mimeType == "video/quicktime" || mimeType == "video/mp4" || mimeType == "video/x-m4v" || mimeType == "video/x-ms-wmv" || mimeType == "video/mpeg" || mimeType == "video/mpg" || mimeType == "video/x-msvideo" || mimeType == "video/avi" || mimeType == "video/x-flv" || mimeType == "video/webm" || mimeType == "application/x-shockwave-flash" {
                return .video
            } else if mimeType == "audio/mpegurl" {
                return .audio
            } else if mimeType == "image/gif" {
                return .gif
            } else if mimeType.hasPrefix("image") {
                return .image
            } else if mimeType == "application/pdf" {
                return .pdf
            }
        }
        return nil
    }
    
    func thumbnailForLocalURL() -> UIImage? {
        var image: UIImage?
        if self.isFileURL, let contentType = self.contentType {
            switch contentType {
            case .video, .audio:
                let asset = AVURLAsset(url: self, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                do {
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    image = UIImage(cgImage: cgImage)
                    
                    // There have been occurrences of videos that have preferred transforms that make the orientation wrong on the UIImage creation.
                    if let track = asset.tracks(withMediaType: .video).first, track.preferredTransform != .identity  {
                        var orientation = UIImage.Orientation.up
                        let videoAngleInDegree = atan2(track.preferredTransform.b, track.preferredTransform.a) * 180 / .pi
                        switch videoAngleInDegree {
                        case 0:
                            orientation = .up
                        case 90:
                            orientation = .right
                        case 180:
                            orientation = .down
                        case -90:
                            orientation = .left
                        default:
                            break
                        }
                        image = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
                    }
                } catch {
                    print(error)
                }
            case .pdf:
                if let temporaryThumbnailURL = self.temporaryThumbnailForPDF(), let data = try? Data(contentsOf: temporaryThumbnailURL) {
                    image = UIImage(data: data)
                }
            case .image, .gif:
                // This is the most optimal way to create a thumb from a local file. Most other ways will cause huge memory leaks.
                image = UIImage(contentsOfFile: self.path) // Will display first frame of gif.
            }
        }
        return image?.normalizedImage()
    }
    
    private func temporaryThumbnailForPDF() -> URL? {
        if let pdf = CGPDFDocument(self as CFURL), let page = pdf.page(at: 1) {
            let rect = page.getBoxRect(.cropBox)
            
            UIGraphicsBeginImageContext(rect.size)
            if let context = UIGraphicsGetCurrentContext() {
                context.saveGState()
                context.translateBy(x: 0.0, y: rect.size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                
                context.setFillColor(gray: 1.0, alpha: 1.0)
                context.fill(rect)
                
                let transform = page.getDrawingTransform(.cropBox, rect: rect, rotate: 0, preserveAspectRatio: true)
                context.concatenate(transform)
                context.drawPDFPage(page)
                
                let image = UIGraphicsGetImageFromCurrentImageContext()
                context.restoreGState()
                UIGraphicsEndImageContext()
                
                return image?.saveJPEGInTempFolder()
            }
        }
        return nil
    }
    
    func sizeForLocalFile() -> Int64? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: self.relativePath)
            return attr[FileAttributeKey.size] as? Int64
        } catch {
            return nil
        }
    }
    
    func downloadToTempDirectory(withCompletion completion: @escaping (URL?, Error?) -> ()) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: self)
        
        let task = session.downloadTask(with: request) { (tempLocalURL, response, error) in
            if let tempLocalURL = tempLocalURL, error == nil {
                let tempDirectory = URL.init(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                let targetURL = tempDirectory.appendingPathComponent(UUID().uuidString)
                do {
                    let data = try Data(contentsOf: tempLocalURL)
                    FileManager.default.createFile(atPath: targetURL.path, contents: data, attributes: nil)
                    DispatchQueue.main.async {
                        completion(targetURL, nil)
                    }
                } catch let writeError {
                    print("Error writing file \(targetURL) : \(writeError)")
                    DispatchQueue.main.async {
                        completion(nil, writeError)
                    }
                }
            } else {
                if error != nil {
                    print(error!.localizedDescription)
                }
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// - Returns: Whether or not the file at the URL exists.
    var localURLIsReachable: Bool {
        if self.isFileURL {
            do {
                return try self.checkResourceIsReachable()
            } catch {
                return false
            }
        }
        return false
    }
    
    var queryItems: [URLQueryItem] {
        return URLComponents(
            url: self,
            resolvingAgainstBaseURL: false)?
            .queryItems
            ?? []
    }
    
    // MARK: Helpers
    
    private static func baseDomain(withPath path: String) -> URL {
        let urlString: String = "\(URL.baseDomain)\(path)"
        return self.init(string: urlString)!
    }
}
