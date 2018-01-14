//
//  FilmDetail.swift
//  WhatFilm
//
//  Created by Julien Ducret on 28/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

public final class FilmDetail: Film {
    
    // MARK: - Properties
    
    let homepage: URL?
    let imdbId: Int?
    let filmOverview: String?
    let runtime: Int?
    let videos: [Video]
    
    // MARK: - JSONInitializable initializer
    
    public required init(json: JSON) {
        self.homepage = json["homepage"].url
        self.imdbId = json["imdb_id"].int
        self.filmOverview = json["overview"].string
        self.runtime = json["runtime"].int
        self.videos = json["videos"]["results"].arrayValue.flatMap({ Video(json: $0) })
        super.init(json: json)
    }
}
