//
//  Endpoint.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/21/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

enum Endpoint: RequestProtocol {
    
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
    
    // MARK: - Properties
    
    private var page: Int? {
        switch self {
        case .searchFilms(let parameters): return parameters.page
        case .popularFilms(let page): return page
        case .upcomingFilms(let page): return page
        case .discoverFilms(let parameters): return parameters.page
        default: return nil
        }
    }
    
    // MARK: - RequestProtocol
    
    var path: String {
        switch self {
        case .configuration: return "/3/configuration"
        case .searchFilms: return "/3/search/movie"
        case .popularFilms: return "/3/movie/popular"
        case .upcomingFilms: return "/3/movie/upcoming"
        case .discoverFilms: return "/3/discover/movie"
        case .filmDetail(let filmId): return "/3/movie/\(filmId)"
        case .filmCredits(let filmId): return "/3/movie/\(filmId)/credits"
        case .person(let id): return "/3/person/\(id)"
        case .personCredits(let id): return "/3/person/\(id)/movie_credits"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .configuration: return .get
        case .searchFilms: return .get
        case .popularFilms: return .get
        case .upcomingFilms: return .get
        case .discoverFilms: return .get
        case .filmDetail: return .get
        case .filmCredits: return .get
        case .person: return .get
        case .personCredits: return .get
        }
    }
    
    var body: RequestBody? {
        return nil
    }
    
    var headers: [String: String] {
        return [:]
    }
    
    var parameters: [URLParameter] {
        var urlParameters = [URLParameter]()
        if let page = page { urlParameters.append(key: "page", value: "\(page + 1)") }
        switch self {
        case .filmDetail: urlParameters.append(key: "append_to_response", value: "videos")
        case .person: urlParameters.append(key: "append_to_response", value: "images")
        default: break
        }
        return urlParameters
    }
}
