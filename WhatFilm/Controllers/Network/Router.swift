//
//  Router.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import Alamofire

// MARK: - OrderingCriteria enum

public enum OrderingCriteria {
    
    // MARK: - Properties
    
    var stringPath: String {
        switch self {
        case .ascending: return ".asc"
        case .descending: return ".desc"
        }
    }
    
    // MARK: - Cases
    
    case ascending
    case descending
}

// MARK: - FilmSortingCriteria enum

public enum FilmSortingCriterion {
    
    // MARK: - Properties
    
    var URLParameter: String {
        switch self {
        case .popularity(let order): return "popularity" + order.stringPath
        case .releaseDate(let order): return "release_date" + order.stringPath
        case .revenue(let order): return "revenue" + order.stringPath
        case .primaryReleaseDate(let order): return "primary_release_date" + order.stringPath
        case .originalTitle(let order): return "original_title" + order.stringPath
        case .voteAverageCount(let order): return "vote_average" + order.stringPath
        case .voteCount(let order): return "vote_count" + order.stringPath
        }
    }
    
    // MARK: - Cases
    
    case popularity(order: OrderingCriteria)
    case releaseDate(order: OrderingCriteria)
    case revenue(order: OrderingCriteria)
    case primaryReleaseDate(order: OrderingCriteria)
    case originalTitle(order: OrderingCriteria)
    case voteAverageCount(order: OrderingCriteria)
    case voteCount(order: OrderingCriteria)
}

// MARK:

public struct DiscoverParameters {
    
    // MARK: - Properties
    
    let sortBy: FilmSortingCriterion
    let page: Int?
    
    // MARK: - Initializers
    
    init(sortBy sortingCriterion: FilmSortingCriterion, atPage page: Int? = nil) {
        self.sortBy = sortingCriterion
        self.page = page
    }
}

// MARK: -

extension DiscoverParameters: URLParametersListSerializable {
    
    // MARK: - URLParametersListSerializable
    
    var URLParametersList: ParametersList {
        var parameters: ParametersList = ParametersList()
        parameters["sort_by"] = self.sortBy.URLParameter
        if let page = self.page { parameters["page"] = "\(page + 1)" } // Pagination starts at 1 on TMDb API
        return parameters
    }
}

// MARK:

public struct FilmSearchParameters {
    
    // MARK: - Properties
    
    let query: String
    let page: Int?
    let language: String?
    let includeAdult: Bool?
    let year: Int?
    let primaryReleaseYear: Int?
    
    var nextPage: FilmSearchParameters {
        guard let page = self.page else { return self }
        return FilmSearchParameters(query: self.query, page: page + 1, language: self.language, includeAdult: self.includeAdult, year: self.year, primaryReleaseYear: self.primaryReleaseYear)
    }
    
    // MARK: - Initializers
    
    init(query: String, page: Int?, language: String?, includeAdult: Bool?, year: Int?, primaryReleaseYear: Int?) {
        self.query = query
        self.page = page
        self.language = language
        self.includeAdult = includeAdult
        self.year = year
        self.primaryReleaseYear = primaryReleaseYear
    }
    
    init(query: String) {
        self.query = query
        self.page = nil
        self.language = nil
        self.includeAdult = nil
        self.year = nil
        self.primaryReleaseYear = nil
    }
    
    init(query: String, atPage page: Int) {
        self.query = query
        self.page = page
        self.language = nil
        self.includeAdult = nil
        self.year = nil
        self.primaryReleaseYear = nil
    }
}

// MARK: -

extension FilmSearchParameters: URLParametersListSerializable {
    
    // MARK: - URLParametersListSerializable
    
    var URLParametersList: ParametersList {
        var parameters: ParametersList = Dictionary()
        parameters["query"] = self.query
        if let page = self.page { parameters["page"] = "\(page + 1)" } // Pagination starts at 1 on TMDb API
        if let language = self.language { parameters["language"] = language }
        if let includeAdult = self.includeAdult , includeAdult == true { parameters["include_adult"] = "true" }
        if let year = self.year { parameters["year"] = "\(year)" }
        if let primaryReleaseYear = self.primaryReleaseYear { parameters["primary_release_year"] = "\(primaryReleaseYear)" }
        return parameters
    }
}

// MARK: - URLRequestConvertible enum

public enum Router: URLRequestConvertible {
    
    // MARK: - Properties
    
    static let BaseURL: URL = URL(string: "https://api.themoviedb.org/3")!
    
    static let TMDbAPIKey: String = {
        guard let filePath: String = Bundle.main.path(forResource: "Services", ofType: "plist") else { fatalError("Couldn't find Services.plist") }
        guard let dict = NSDictionary(contentsOfFile: filePath) else { fatalError("Can't read Services.plist") }
        guard let apiKey = dict["TMDbAPIKey"] as? String else { fatalError("Couldn't find a value for 'TMDbAPIKey'") }
        return apiKey
    }()
    
    var path: String {
        switch self {
        case .configuration: return "/configuration"
        case .searchFilms(_): return "/search/movie"
        case .popularFilms(_): return "/movie/popular"
        case .upcomingFilms(_): return "/movie/upcoming"
        case .discoverFilms(_): return "/discover/movie"
        case .filmDetail(let filmId): return "/movie/\(filmId)"
        case .filmCredits(let filmId): return "/movie/\(filmId)/credits"
        case .person(let id): return "/person/\(id)"
        case .personCredits(let id): return "/person/\(id)/movie_credits"
        }
    }
    
    var httpMethod: Alamofire.HTTPMethod {
        switch self {
        case .configuration: return .get
        case .searchFilms(_): return .get
        case .popularFilms(_): return .get
        case .upcomingFilms(_): return .get
        case .discoverFilms(_): return .get
        case .filmDetail(_): return .get
        case .filmCredits(_): return .get
        case .person(_): return .get
        case .personCredits(_): return .get
        }
    }
    
    // MARK: - Cases
    
    case configuration
    case searchFilms(parameters: FilmSearchParameters)
    case popularFilms(page: Int?)
    case upcomingFilms(page: Int?)
    case discoverFilms(parameters: DiscoverParameters)
    case filmDetail(filmId: Int)
    case filmCredits(filmId: Int)
    case person(id: Int)
    case personCredits(id: Int)
    
    // MARK: - URLRequestConvertible overriden properties / functions
    
    public func asURLRequest() throws -> URLRequest {
        
        let url: URL = Router.BaseURL.appendingPathComponent(self.path)
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = self.httpMethod.rawValue
        
        let finalRequest: URLRequest = try {
            switch self {
                
            case .configuration:
                
                var urlParameters = ParametersList()
                urlParameters["api_key"] = Router.TMDbAPIKey
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .searchFilms(let parameters):
                
                var urlParameters = parameters.URLParametersList
                urlParameters["api_key"] = Router.TMDbAPIKey
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .popularFilms(let page):
                
                var urlParameters = ParametersList()
                urlParameters["api_key"] = Router.TMDbAPIKey
                if let page = page { urlParameters["page"] = "\(page + 1)" }
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .upcomingFilms(let page):
                
                var urlParameters = ParametersList()
                urlParameters["api_key"] = Router.TMDbAPIKey
                if let page = page { urlParameters["page"] = "\(page + 1)" }
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .discoverFilms(let parameters):
                
                var urlParameters = parameters.URLParametersList
                urlParameters["api_key"] = Router.TMDbAPIKey
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .filmDetail(_):
                
                var urlParameters = ParametersList()
                urlParameters["api_key"] = Router.TMDbAPIKey
                urlParameters["append_to_response"] = "videos"
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .filmCredits(_):
                
                var urlParameters = ParametersList()
                urlParameters["api_key"] = Router.TMDbAPIKey
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .person(_):
                
                var urlParameters = ParametersList()
                urlParameters["api_key"] = Router.TMDbAPIKey
                urlParameters["append_to_response"] = "images"
                return try URLEncoding.queryString.encode(request, with: urlParameters)
                
            case .personCredits(_):
                
                var urlParameters = ParametersList()
                urlParameters["api_key"] = Router.TMDbAPIKey
                return try URLEncoding.queryString.encode(request, with: urlParameters)
            }
        }()
//        print("[ROUTER] \(finalRequest.url?.absoluteString ?? " - ")")
        return finalRequest
    }
}
