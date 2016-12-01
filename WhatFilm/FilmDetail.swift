//
//  FilmDetail.swift
//  WhatFilm
//
//  Created by Julien Ducret on 28/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

public final class FilmDetail: NSObject, JSONInitializable {
    
    // MARK: - Properties
    
    let id: Int
    let posterPathString: String?
    let adult: Bool
    let overview: String
    let releaseDate: Date
    let genreIds: [Int]
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let backdropPathString: String?
    let popularity: Double
    let voteCount: Int
    let video: Bool
    let voteAverage: Double
    let homepage: URL?
    let imdbId: Int?
    let filmOverview: String?
    let runtime: Int?
    let videos: [Video]
    
    // MARK: - Computed properties
    
    var fullTitle: String {
        let date = self.releaseDate as NSDate
        return self.title + " (\(date.year()))"
    }
    
    var posterPath: ImagePath? {
        guard let posterPathString = self.posterPathString else { return nil }
        return ImagePath.poster(path: posterPathString)
    }
    
    var backdropPath: ImagePath? {
        guard let backdropPathString = self.backdropPathString else { return nil }
        return ImagePath.backdrop(path: backdropPathString)
    }
    
    // MARK: - JSONInitializable initializer
    
    public init(json: JSON) {
        self.id = json["id"].intValue
        self.posterPathString = json["poster_path"].string
        self.adult = json["adult"].boolValue
        self.overview = json["overview"].stringValue
        self.releaseDate = json["release_date"].dateValue
        self.genreIds = json["genre_ids"].arrayValue.flatMap({ $0.int })
        self.originalTitle = json["original_title"].stringValue
        self.originalLanguage = json["original_language"].stringValue
        self.title = json["title"].stringValue
        self.backdropPathString = json["backdrop_path"].string
        self.popularity = json["popularity"].doubleValue
        self.voteCount = json["popularity"].intValue
        self.video = json["video"].boolValue
        self.voteAverage = json["vote_average"].doubleValue
        self.homepage = json["homepage"].URL
        self.imdbId = json["imdb_id"].int
        self.filmOverview = json["overview"].string
        self.runtime = json["runtime"].int
        self.videos = json["videos"]["results"].arrayValue.flatMap({ Video(json: $0) })
        super.init()
    }
}
