//
//  ImageManager.swift
//  WhatFilm
//
//  Created by Julien Ducret on 13/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

public enum ImageSize {
    
    // MARK: - Cases
    
    case small
    case medium
    case big
    case original
    
}

// MARK: -

public enum ImagePath {
    
    // MARK: - Cases
    
    case backdrop(path: String)
    case logo(path: String)
    case poster(path: String)
    case profile(path: String)
    case still(path: String)
    
    // MARK: - Properties
    
    var path: String {
        switch self {
        case .backdrop(let path): return path
        case .logo(let path): return path
        case .poster(let path): return path
        case .profile(let path): return path
        case .still(let path): return path
        }
    }
}

// MARK: -

public final class ImageManager: NSObject {
    
    // MARK: - Properties
    
    fileprivate let apiConfiguration: APIConfiguration
    
    // MARK: - Initializer
    
    public init(apiConfiguration: APIConfiguration) {
        self.apiConfiguration = apiConfiguration
    }
    
    // MARK: - Helper functions
    
    private func pathComponent(forSize size: ImageSize, andPath imagePath: ImagePath) -> String {
        let array: [String] = {
            switch imagePath {
                case .backdrop: return self.apiConfiguration.backdropSizes
                case .logo: return self.apiConfiguration.logoSizes
                case .poster: return self.apiConfiguration.posterSizes
                case .profile: return self.apiConfiguration.profileSizes
                case .still: return self.apiConfiguration.stillSizes
            }
        }()
        let sizeComponentIndex: Int = {
            switch size {
                case .small: return 0
                case .medium: return array.count / 2
                case .big: return array.count - 2
                case .original: return array.count - 1
            }
        }()
        let sizeComponent: String = array[sizeComponentIndex]
        return "\(sizeComponent)/\(imagePath.path)"
    }
    
    func url(fromTMDbPath imagePath: ImagePath, withSize size: ImageSize) -> URL? {
        let pathComponent = self.pathComponent(forSize: size, andPath: imagePath)
        return URL(string: self.apiConfiguration.imagesSecureBaseURLString)?.appendingPathComponent(pathComponent)
    }
}
