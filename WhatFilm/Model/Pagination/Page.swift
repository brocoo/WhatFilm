//
//  Page.swift
//  WhatFilm
//
//  Created by Julien Ducret on 3/21/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

public struct Page<T: Decodable> {
    
    // MARK: - Properties
    
    let pageIndex: Int
    let totalResults: Int
    let totalPages: Int
    private let results: [T]
    
    // MARK: - Computed properties
    
    var nextPageIndex: Int { return pageIndex + 1 }
    var hasNextPage: Bool { return nextPageIndex < totalPages }
    var asArray: [T] { return results }
    
    // MARK: - Initializer
    
    init(pageIndex: Int, totalResults: Int, totalPages: Int, results: [T]) {
        self.pageIndex = pageIndex
        self.totalResults = totalResults
        self.totalPages = totalPages
        self.results = results
    }
}

// MARK: -

extension Page: RandomAccessCollection {
    
    // MARK: - RandomAccessCollection
    
    public var startIndex: Int {
        return results.startIndex
    }
    
    public var endIndex: Int {
        return results.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return results.index(after: i)
    }
    
    public subscript(index: Int) -> T {
        return results[index]
    }
}

// MARK: -

extension Page: Decodable {
    
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
        let pageIndex = try container.decode(Int.self, forKey: .page) - 1
        let totalResults = try container.decode(Int.self, forKey: .totalResults)
        let totalPages = try container.decode(Int.self, forKey: .totalPages)
        let results = try container.decode([T].self, forKey: .results)
        self.init(pageIndex: pageIndex, totalResults: totalResults, totalPages: totalPages, results: results)
    }
}
