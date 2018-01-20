//
//  PaginatedList.swift
//  WhatFilm
//
//  Created by Julien Ducret on 16/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public struct PaginatedList<T: Decodable> {

    // MARK: - Properties
    
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [T]
    
    // MARK: - Initializer
    
    init(page: Int, totalResults: Int, totalPages: Int, results: [T]) {
        self.page = page
        self.totalResults = totalResults
        self.totalPages = totalPages
        self.results = results
    }
    
    // MARK: - Helper functions / properties
    
    var count: Int { return self.results.count }
    
    var nextPage: Int? {
        let nextPage = self.page + 1
        guard nextPage < self.totalPages else { return nil }
        return nextPage
    }
    
    static func Empty() -> PaginatedList { return PaginatedList(page: 0, totalResults: 0, totalPages: 0, results: []) }
}

// MARK: -

extension PaginatedList: Decodable {
    
    // MARK: - Keys
    
    private enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
    
    // MARK: - Initializer
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let page = try container.decode(Int.self, forKey: .page) - 1
        let totalResults = try container.decode(Int.self, forKey: .totalResults)
        let totalPages = try container.decode(Int.self, forKey: .totalPages)
        let results = try container.decode([T].self, forKey: .results)
        self.init(page: page, totalResults: totalResults, totalPages: totalPages, results: results)
    }
}

// MARK: -

extension PaginatedList {
    
    // MARK: - Subscript
    
    subscript(index: Int) -> T {
        return self.results[index]
    }
}
