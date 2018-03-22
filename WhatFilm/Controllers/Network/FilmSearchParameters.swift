//
//  FilmSearchParameters.swift
//  WhatFilm
//
//  Created by Julien Ducret on 2/5/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

public struct FilmSearchParameters {
    
    // MARK: - Properties
    
    let query: String
    var page: Int?
    let language: String?
    let includeAdult: Bool?
    let year: Int?
    let primaryReleaseYear: Int?
    
    // MARK: - Initializers
    
    init(query: String, page: Int? = nil, language: String? = nil, includeAdult: Bool? = nil, year: Int? = nil, primaryReleaseYear: Int? = nil) {
        self.query = query
        self.page = page
        self.language = language
        self.includeAdult = includeAdult
        self.year = year
        self.primaryReleaseYear = primaryReleaseYear
    }
    
    // MARK: - Helper functions
    
    func forPage(_ page: Int) -> FilmSearchParameters {
        var newParameters = self
        newParameters.page = page
        return newParameters
    }
}

// MARK: -

extension FilmSearchParameters: URLParametersSerializable {
    
    // MARK: - URLParametersListSerializable
    
    var asURLParameters: [URLParameter] {
        var parameters = [URLParameter]()
        parameters.append(key: "query", value: query)
        if let page = page { parameters.append(key: "page", value: "\(page + 1)") } // Pagination starts at 1 on TMDb API
        if let language = language { parameters.append(key: "language", value: language) }
        if let includeAdult = includeAdult , includeAdult == true { parameters.append(key: "include_adult", value: "true") }
        if let year = year { parameters.append(key: "year", value: "\(year)") }
        if let primaryReleaseYear = primaryReleaseYear { parameters.append(key: "primary_release_year", value: "\(primaryReleaseYear)") }
        return parameters
    }
}
