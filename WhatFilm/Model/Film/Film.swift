//
//  Film.swift
//  WhatFilm
//
//  Created by Julien Ducret on 12/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public class Film: Decodable {
    
    // MARK: - Keys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case posterPathString = "poster_path"
        case adult
        case overview
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case title
        case backdropPathString = "backdrop_path"
        case popularity
        case video
        case voteAverage = "vote_average"
    }
    
    // MARK: - Properties
    
    let id: Int
    let posterPathString: String?
    let adult: Bool
    let overview: String
    let releaseDate: Date?
    let genreIds: [Int]
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let backdropPathString: String?
    let popularity: Double
    let video: Bool
    let voteAverage: Double
    
    // MARK: - Computed properties
    
    var fullTitle: String {
        guard let date = releaseDate else { return title }
        return self.title + " (\((date as NSDate).year()))"
    }
    
    var posterPath: ImagePath? {
        guard let posterPathString = self.posterPathString else { return nil }
        return ImagePath.poster(path: posterPathString)
    }
    
    var backdropPath: ImagePath? {
        guard let backdropPathString = self.backdropPathString else { return nil }
        return ImagePath.backdrop(path: backdropPathString)
    }
    
    var voteCount: Int { return Int(popularity) }
    
    // MARK: - JSONInitializable initializer
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.posterPathString = try container.decodeIfPresent(String.self, forKey: .posterPathString)
        self.adult = try container.decode(Bool.self, forKey: .adult)
        self.overview = try container.decode(String.self, forKey: .overview)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)?.asISO8601Date
        self.genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
        self.originalTitle = try container.decode(String.self, forKey: .originalTitle)
        self.originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        self.title = try container.decode(String.self, forKey: .title)
        self.backdropPathString = try container.decodeIfPresent(String.self, forKey: .backdropPathString)
        self.popularity = try container.decode(Double.self, forKey: .popularity)
        self.video = try container.decode(Bool.self, forKey: .video)
        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
    }
}

// MARK: -

extension Film: CustomStringConvertible {
    
    // MARK: - Description
    
    public var description: String {
        guard let date = releaseDate else { return originalTitle }
        let dateString: String = DateManager.sharedFormatter.string(from: date)
        return "\(originalTitle) (\(dateString))"
    }
}

// MARK: -

extension Array where Element: Film {
    
    var withoutDuplicates: [Film] {
        var exists: [Int: Bool] = [:]
        return self.filter { exists.updateValue(true, forKey: $0.id) == nil }
    }
}
