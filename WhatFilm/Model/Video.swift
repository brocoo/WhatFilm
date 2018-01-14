//
//  Video.swift
//  WhatFilm
//
//  Created by Julien Ducret on 07/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

final class Video: NSObject, JSONFailableInitializable {

    // MARK: - Properties
    
    let id: Int
    let key: String
    let name: String
    let size: Int
    
    // MARK: - Computed properties
    
    var youtubeURL: URL? { return URL(string: "https://www.youtube.com/watch?v=\(self.key)") }
    
    var youtubeThumbnailURL: URL? { return URL(string: "https://img.youtube.com/vi/\(self.key)/0.jpg") }
    
    // MARK: - Initializer
    
    init?(json: JSON) {
        guard let key = json["key"].string else { return nil }
        guard let site = json["site"].string, site == "YouTube" else { return nil }
        self.id = json["id"].intValue
        self.key = key
        self.name = json["name"].stringValue
        self.size = json["size"].intValue
        super.init()
    }
}
