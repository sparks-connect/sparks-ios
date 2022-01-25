//
//  PHAsset+Extentions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Photos

import MobileCoreServices
import UIKit

import UIKit

typealias ViewableCompletion = () -> Void
typealias ViewableImageCompletion = (UIImage?) -> Void

protocol Viewable {
    
    var contentURL: URL? { get }
    var contentType: URLContentType { get }
    var needsToBeDownloaded: Bool { get }
    
    func fetchThumbnailImage(withCompletion completion: @escaping ViewableImageCompletion)
    func downloadForContentView(withCompletion completion: @escaping ViewableCompletion)
    
}

enum PHAssetType: Int {
    case gif
    case video
}

extension PHAsset {
    
    func downloadFile(withCompletion completion: @escaping (_ url: URL?) -> Void) {
        if self.mediaType == .image {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImageData(for: self, options: options) { (data, uti, orientation, info) in
                if let data = data {
                    if let uti = uti, UTTypeConformsTo(uti as CFString, kUTTypeGIF) {
                        if let url = data.saveInTempFolder(withExtension: "gif") {
                            completion(url)
                        } else {
                            completion(nil)
                        }
                    } else {
                        let image = UIImage(data: data)
                        let url = image?.saveJPEGInTempFolder()
                        completion(url)
                    }
                } else {
                    completion(nil)
                }
            }
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .current
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let uuid = UUID().uuidString
                    let path = NSTemporaryDirectory() + "/\(uuid).\(urlAsset.url.lastPathComponent)"
                    let url = URL(fileURLWithPath: path)
                    do {
                        try FileManager.default.copyItem(at: urlAsset.url, to: url)
                        DispatchQueue.main.async {
                            completion(url)
                        }
                    } catch {
                        print(error)
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else {
                    // Slow-mo videos aren't handled yet. -LQ
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
    
}

typealias PhotoAssetCompletion = () -> Void

class PhotoAsset: NSObject {
    
    init(withAsset asset: PHAsset) {
        self.asset = asset
        
        super.init()
    }
    
    init(withURL url: URL, id: String) {
        self.url = url
        self.id = id
        super.init()
    }
    
    var asset: PHAsset?
    var url: URL?
    var id: String?

    final func downloadFile(withCompletion completion: PhotoAssetCompletion? = nil) {
        self.asset?.downloadFile { [weak self] (url) in
            self?.url = url
            completion?()
        }
    }
    
}

extension PhotoAsset: Viewable {
    
    var contentURL: URL? {
        return self.url
    }
    
    var contentType: URLContentType {
        if let contentType = self.url?.contentType {
            return contentType
        }
        return .image
    }
    
    var needsToBeDownloaded: Bool {
        if let url = self.url, url.localURLIsReachable {
            return false
        }
        return true
    }
    
    final func fetchThumbnailImage(withCompletion completion: ViewableImageCompletion) {
        completion(self.url?.thumbnailForLocalURL())
    }
    
    final func downloadForContentView(withCompletion completion: @escaping ViewableCompletion) {
        self.downloadFile(withCompletion: completion)
    }
    
}
