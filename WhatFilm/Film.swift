//
//  Film.swift
//  WhatFilm
//
//  Created by Julien Ducret on 12/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxDataSources

public final class Film: NSObject, JSONInitializable {
    
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
    
    // MARK: - Computed properties
    
    var fullTitle: String {
        return self.title
    }
    
    var posterPath: ImagePath? {
        guard let posterPathString = self.posterPathString else { return nil }
        return ImagePath.poster(path: posterPathString)
    }
    
    var backdropPath: ImagePath? {
        guard let posterPathString = self.posterPathString else { return nil }
        return ImagePath.poster(path: posterPathString)
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
        super.init()
    }
}

// MARK: -

extension Film: IdentifiableType {
    
    // MARK: - IdentifiableType
    
    public typealias Identity = Int
    public var identity: Identity { return self.id }
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
