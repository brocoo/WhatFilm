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
        case voteCount = "vote_count"
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
    let voteCount: Int
    
    // MARK: - Lazy properties
    
    private(set) lazy var fullTitle: String = {
        guard let date = releaseDate else { return title }
        return self.title + " (\((date as NSDate).year()))"
    }()
    
    private(set) lazy var posterPath: ImagePath? = {
        guard let posterPathString = self.posterPathString else { return nil }
        return ImagePath.poster(path: posterPathString)
    }()
    
    private(set) lazy var backdropPath: ImagePath? = {
        guard let backdropPathString = self.backdropPathString else { return nil }
        return ImagePath.backdrop(path: backdropPathString)
    }()
    
    // MARK: - Decoder initializer
    
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
        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
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

extension Film: Equatable {
    
    // MARK: - Equatable
    
    public static func ==(lhs: Film, rhs: Film) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: -

extension Film: Hashable {
    
    // MARK: - Hashable
    
    public var hashValue: Int { return id }
}

// MARK: -

extension Array where Element: Film {
    
    var withoutDuplicates: [Film] {
        var exists: [Int: Bool] = [:]
        return self.filter { exists.updateValue(true, forKey: $0.id) == nil }
    }
}
