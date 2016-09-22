//
//  Film.swift
//  WhatFilm
//
//  Created by Julien Ducret on 12/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

public final class Film: NSObject, JSONInitializable {
    
    // MARK: - Properties
    
    let id: Int
    let posterPath: String?
    let adult: Bool
    let overview: String
    let releaseDate: Date
    let genreIds: [Int]
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let backdropPath: String?
    let popularity: Double
    let voteCount: Int
    let video: Bool
    let voteAverage: Double
    
    // MARK: - Computed properties
    
    var fullTitle: String {
        return self.title
    }
    
    // MARK: - JSONInitializable initializer
    
    public init(json: JSON) {
        self.id = json["id"].intValue
        self.posterPath = json["poster_path"].string
        self.adult = json["adult"].boolValue
        self.overview = json["overview"].stringValue
        self.releaseDate = json["release_date"].dateValue
        self.genreIds = json["genre_ids"].arrayValue.flatMap({ $0.int })
        self.originalTitle = json["original_title"].stringValue
        self.originalLanguage = json["original_language"].stringValue
        self.title = json["title"].stringValue
        self.backdropPath = json["backdrop_path"].string
        self.popularity = json["popularity"].doubleValue
        self.voteCount = json["popularity"].intValue
        self.video = json["video"].boolValue
        self.voteAverage = json["vote_average"].doubleValue
        super.init()
    }
}

// MARK: -

extension Film {
    
    // MARK: - Description
    
    public override var description: String {
        let dateString: String = DateManager.SharedFormatter.string(from: self.releaseDate)
        return "\(self.originalTitle) (\(dateString))"
    }
    
    public override var debugDescription: String { return self.description }
}
