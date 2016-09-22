//
//  ImageManager.swift
//  WhatFilm
//
//  Created by Julien Ducret on 13/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

public final class ImageManager: NSObject {
    
    // MARK: - Properties
    
    fileprivate let baseURL: URL
    fileprivate let backdropSizesPaths: [String]
    fileprivate let logoSizesPaths: [String]
    fileprivate let posterSizesPaths: [String]
    fileprivate let profileSizesPaths: [String]
    fileprivate let stillSizesPaths: [String]
    
    // MARK: - Initializer
    
    public init(json: JSON) {
        guard let url = json["secure_base_url"].URL else { fatalError("Couldn't build the images base URL from JSON retrieved") }
        self.baseURL = url
        self.backdropSizesPaths = json["backdrop_sizes"].arrayValue.flatMap({ $0.string })
        self.logoSizesPaths = json["logo_sizes"].arrayValue.flatMap({ $0.string })
        self.posterSizesPaths = json["poster_sizes"].arrayValue.flatMap({ $0.string })
        self.profileSizesPaths = json["profile_sizes"].arrayValue.flatMap({ $0.string })
        self.stillSizesPaths = json["still_sizes"].arrayValue.flatMap({ $0.string })
        super.init()
    }
}
