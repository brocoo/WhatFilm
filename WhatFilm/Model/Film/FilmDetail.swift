//
//  FilmDetail.swift
//  WhatFilm
//
//  Created by Julien Ducret on 28/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class FilmDetail: Film {
    
    // MARK: - Keys
    
    private enum CodingKeys: String, CodingKey {
        case homepage
        case imdbId
        case filmOverview
        case runtime
        case videos
        case results
    }
    
    // MARK: - Properties
    
    let homepage: URL?
    let imdbId: Int?
    let filmOverview: String?
    let runtime: Int?
    let videos: [Video]
    
    // MARK: - JSONInitializable initializer
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.homepage = try container.decodeIfPresent(String.self, forKey: .homepage)?.asURL
        self.imdbId = try container.decodeIfPresent(Int.self, forKey: .imdbId)
        self.filmOverview = try container.decodeIfPresent(String.self, forKey: .filmOverview)
        self.runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        self.videos = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .videos).decode([Video].self, forKey: .results)
        try super.init(from: decoder)
    }
}
