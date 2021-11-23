//
//  Storage.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/19/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import Firebase
import SDWebImage

/// Storage
protocol IStorageAPI: AnyObject {
    @discardableResult func uploadFile(from url: URL, completion:((Result<String, Error>) -> Void)?, progressBlock: ((Progress?)->Void)?) -> TaskIdentifier
    @discardableResult func uploadFile(to path: String, from url: URL, completion:((Result<String, Error>) -> Void)?, progressBlock: ((Progress?)->Void)?) -> TaskIdentifier
    @discardableResult func uploadFile(to path: String, file: Data, contentType: String, completion:((Result<String, Error>) -> Void)?, progressBlock: ((Progress?)->Void)?) -> TaskIdentifier
    func deleteFile(to path: String, completion: ((Result<String, Error>) -> Void)?)
    func cancelTask(uid: TaskIdentifier)
}

typealias TaskIdentifier = String

class StorageAPIImpl : IStorageAPI {
    
    private let storage = Storage.storage()
    private lazy var taskDataSource = [String: StorageUploadTask]()
    
    private let taskQueue = DispatchQueue(label: "com.farming.uploadtaskqueue", qos: .default, attributes: .concurrent)
    
    @discardableResult
    func uploadFile(from url: URL, completion:((Result<String, Error>) -> Void)?, progressBlock: ((Progress?)->Void)? = nil) -> TaskIdentifier {
        return self.uploadFile(to: "\(UUID.init().uuidString).jpg", from: url, completion: completion, progressBlock: progressBlock)
    }
    
    @discardableResult
    func uploadFile(to path: String, from url: URL, completion:((Result<String, Error>) -> Void)?,
                    progressBlock: ((Progress?)->Void)? = nil) -> TaskIdentifier {
        
        let storageRef = storage.reference()
        let profileRef = storageRef.child(path)
        
        var _url = url
        if let reducedURL = self.reduceImageFileSize(url: url) { _url = reducedURL }
        
        let task = profileRef.putFile(from: _url, metadata: nil) { metadata, error in
            guard error == nil else {
                completion?(.failure(error ?? CIError.uploadFailed))
                return
            }
            
            profileRef.downloadURL {[weak self] (__url, error) in
                guard let downloadURL = __url?.absoluteString else {
                    completion?(.failure(error ?? CIError.uploadFailed))
                    return
                }
                //self?.cleanupCache(url: downloadURL)
                completion?(.success(downloadURL))
            }
        }
        
        task.observe(.progress) { (snap) in
            progressBlock?(snap.progress)
        }
        return mapTask(task: task)
    }
    
    private func cleanupCache(url: String) {
        let components = url.components(separatedBy: "&token=")
        SDImageCache.shared.removeImage(forKey: components.first, fromDisk: true, withCompletion: nil)
    }
    
    @discardableResult
    func uploadFile(to path: String, file: Data, contentType: String, completion: ((Result<String, Error>) -> Void)?, progressBlock: ((Progress?) -> Void)?) -> TaskIdentifier {
        let storageRef = storage.reference()
        let profileRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        metadata.cacheControl = "max-age=31536000"
        
        let task = profileRef.putData(file, metadata: metadata) { metadata, error in
            
            guard error == nil else {
                completion?(.failure(error ?? CIError.uploadFailed))
                return
            }
            
            profileRef.downloadURL { (__url, error) in
                guard let downloadURL = __url?.absoluteString else {
                    completion?(.failure(error ?? CIError.uploadFailed))
                    return
                }
                completion?(.success(downloadURL))
            }
        }
        
        task.observe(.progress) { (snap) in
            progressBlock?(snap.progress)
        }
        return mapTask(task: task)
    }
    
    func deleteFile(to path: String, completion: ((Result<String, Error>) -> Void)?) {
        let storageRef = storage.reference()
        let profileRef = storageRef.child(path)
        profileRef.delete { error in
            if let e = error {
                completion?(.failure(e))
            } else {
                completion?(.success(""))
            }
        }
    }
    
    
    private func mapTask(task: StorageUploadTask) -> TaskIdentifier {
        let uid = UUID().uuidString
        self.taskQueue.async(flags: .barrier) { [weak self] in self?.taskDataSource[uid] = task }
        return uid
    }
    
    func cancelTask(uid: TaskIdentifier) {
        self.taskQueue.async { self.taskDataSource[uid]?.cancel() }
    }
    
    private func reduceImageFileSize(url: URL) -> URL? {
        
        guard let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)?.jpegData(compressionQuality: 0.5) else { return nil }
        
        let newURL = FileUtils.tempURL(for: "jpeg")
        if !FileUtils.createFile(at: newURL, data: image) { return nil }
        
        return newURL
    }
}
