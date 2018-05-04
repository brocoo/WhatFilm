//
//  ImageCache.swift
//  WhatFilm
//
//  Created by Julien Ducret on 4/17/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation
import UIKit

final class ImageCache {
    
    // MARK: - Properties
    
    fileprivate lazy var cache: NSCache<NSString, UIImage> = {
        let cache: NSCache<NSString, UIImage> = NSCache()
        cache.totalCostLimit = {
            let physicalMemory = ProcessInfo.processInfo.physicalMemory
            let ratio = physicalMemory <= (1024 * 1024 * 512 /* 512 Mb */) ? 0.1 : 0.2
            let limit = physicalMemory / UInt64(1 / ratio)
            return limit > UInt64(Int.max) ? Int.max : Int(limit)
        }()
        return cache
    }()
    
    fileprivate let fileManager = FileManager()
    fileprivate let cacheDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("com.WhatFilm/cache/images")
    fileprivate let queue = DispatchQueue(label: "com.WhatFilm.cache.diskQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    // MARK: - Initializer

    public init() throws {
        try fileManager.createDirectory(at: cacheDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
    }
    
    // MARK: - Helper functions
    
    fileprivate func diskUrl(`for` key: String) -> URL? {
        guard let sanitizedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return nil }
        return cacheDirectoryUrl.appendingPathComponent(sanitizedKey)
    }
}

// MARK: -

extension ImageCache: RessourceCacheProtocol {
    
    // MARK: - RessourceCacheProtocol associatedtypes
    
    typealias Key = String
    typealias Ressource = UIImage
    
    // MARK: - RessourceCacheProtocol functions
    
    func cachedRessource(for key: String) -> UIImage? {
        var image: UIImage? = nil
        queue.sync {
            if let cachedImage = cache.object(forKey: key as NSString) {
                image = cachedImage
            } else if let url = diskUrl(for: key),
                fileManager.fileExists(atPath: url.path),
                let data = fileManager.contents(atPath: url.path),
                let cachedImage = UIImage(data: data) {
                self.cache.setObject(cachedImage, forKey: key as NSString, cost: cachedImage.cacheCost)
                image = cachedImage
            }
        }
        return image
    }
    
    func cache(_ ressource: UIImage, for key: String) {
        queue.async {
            self.cache.setObject(ressource, forKey: key as NSString, cost: ressource.cacheCost)
            if let url = self.diskUrl(for: key) {
                let data = UIImagePNGRepresentation(ressource)
                try? data?.write(to: url)
            }
        }
    }
}

// MARK: -

extension UIImage {
    
    // MARK: -
    
    fileprivate var cacheCost: Int {
        if let imageRef = cgImage {
            return imageRef.bytesPerRow * imageRef.height
        } else if let data = UIImagePNGRepresentation(self) {
            return data.count
        } else if let data = UIImageJPEGRepresentation(self, 1) {
            return data.count
        } else {
            return 100
        }
    }
}
