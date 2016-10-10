//
//  FilmCredit.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias FilmsCredited = (asCast: [FilmCredited], asCrew: [FilmCredited])

final class FilmCredited: NSObject, JSONFailableInitializable {

    // MARK: - Properties
    
    let category: PersonCategory
    let id: Int
    let posterPathString: String?
    let adult: Bool
    let releaseDate: Date
    let title: String
    
    // MARK: - Computed properties
    
    var fullTitle: String {
        let date = self.releaseDate as NSDate
        return self.title + " (\(date.year()))"
    }
    
    var posterPath: ImagePath? {
        guard let posterPathString = self.posterPathString else { return nil }
        return ImagePath.poster(path: posterPathString)
    }
    
    // MARK: - Initializer
    
    init?(json: JSON) {
        guard let category = PersonCategory(json: json) else { return nil }
        self.id = json["id"].intValue
        self.category = category
        self.posterPathString = json["poster_path"].string
        self.adult = json["adult"].boolValue
        self.releaseDate = json["release_date"].dateValue
        self.title = json["title"].stringValue
        super.init()
    }
}
