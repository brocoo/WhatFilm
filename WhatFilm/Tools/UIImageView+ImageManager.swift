//
//  UIImageView+ImageManager.swift
//  WhatFilm
//
//  Created by Julien Ducret on 4/3/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - UIImageView associated objects handle

var imageViewAPIAssociatedObjectHandle: UInt8 = 0
var imageViewKeyAssociatedObjectHandle: UInt8 = 0

// MARK: -

protocol ImageAPIProtocol: class {
    
    typealias CachedImage = (image: UIImage, cached: Bool)
    
    func image(withSize size: ImageSize, atPath path: ImagePath) -> Observable<CachedImage>
}

// MARK: -

extension UIImageView {
    
    // MARK: -
    
    fileprivate struct Key: Equatable {
        
        let path: ImagePath
        let size: ImageSize
        
        static func == (lhs: Key, rhs: Key) -> Bool {
            return lhs.path == rhs.path && lhs.size == rhs.size
        }
    }
    
    // MARK: - Associated objects
    
    static var api: ImageAPIProtocol? {
        get { return objc_getAssociatedObject(self, &imageViewAPIAssociatedObjectHandle) as? ImageAPIProtocol }
        set { objc_setAssociatedObject(self, &imageViewAPIAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    fileprivate var key: Key? {
        get { return objc_getAssociatedObject(self, &imageViewKeyAssociatedObjectHandle) as? Key }
        set { objc_setAssociatedObject(self, &imageViewKeyAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Helper functions
    
    func setImage(fromPath path: ImagePath, withSize size: ImageSize, withPlaceholder placeholder: UIImage? = nil) {
        guard let api = UIImageView.api else { return }
        let currentKey = Key(path: path, size: size)
        self.key = currentKey
        ImageViewReactiveManager.shared.getImage(forPath: path, size: size, withAPI: api) { [weak self] (cachedImage) in
            DispatchQueue.main.async {
                guard let `self` = self, let key = self.key, key == currentKey else { return }
                if let cachedImage = cachedImage {
                    if self.image == nil {
                        self.alpha = 0.0
                        UIView.animate(withDuration: 0.2) { self.alpha = 1.0 }
                    }
                    self.image = cachedImage.image
                } else {
                    self.image = placeholder
                }
            }
        }
    }
}

// MARK: -

fileprivate final class ImageViewReactiveManager {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    static let shared = ImageViewReactiveManager()
    
    // MARK: - Helper function
    
    fileprivate func getImage(forPath path: ImagePath, size: ImageSize, withAPI api: ImageAPIProtocol, onCompletion completion: @escaping (ImageAPIProtocol.CachedImage?) -> Void) {
        api.image(withSize: size, atPath: path)
            .subscribe(onNext: { (image) in
                completion(image)
            }, onError: { (error) in
                completion(nil)
            }).disposed(by: disposeBag)
    }
}

