//
//  PaginatedList.swift
//  WhatFilm
//
//  Created by Julien Ducret on 3/21/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

// MARK: -

public struct PaginatedList<T: Decodable> {
    
    // MARK: - Action
    
    enum Mutation {
        case created
        case newPageAdded(Int)
    }
    
    // MARK: - Properties
    
    private var contents: [T]
    private var pages: [CountableRange<Int>]
    private(set) var lastContentUpdate: Mutation
    private(set) var hasMoreContent: Bool
    
    // MARK: - Static properties
    
    static var empty: PaginatedList { return PaginatedList() }
    
    // MARK: - Initializer
    
    private init() {
        pages = []
        contents = []
        lastContentUpdate = .created
        hasMoreContent = false
    }
    
    public init(with page: Page<T>) throws {
        guard page.pageIndex == 0 else { throw PaginatedListError.initialPageIndexNotZero(page.pageIndex) }
        contents = page.asArray
        pages = [(0..<contents.endIndex)]
        lastContentUpdate = .created
        hasMoreContent = page.hasNextPage
    }
    
    // MARK: - Helper functions / properties
    
    public mutating func append(_ page: Page<T>) throws {
        let nextPageIndex = pages.count
        if nextPageIndex > 0 {
            guard nextPageIndex == page.pageIndex else { throw PaginatedListError.wrongNextPageIndex(page.pageIndex, expected: nextPageIndex) }
            let startIndex = contents.endIndex
            contents.append(contentsOf: page.asArray)
            pages.append((startIndex..<contents.endIndex))
            lastContentUpdate = .newPageAdded(nextPageIndex)
            hasMoreContent = page.hasNextPage
        } else {
            self = try PaginatedList(with: page)
        }
    }
    
    public func appending(_ page: Page<T>) throws -> PaginatedList<T> {
        var newPagedList = self
        try newPagedList.append(page)
        return newPagedList
    }
    
    public func contents(atPage i: Int) -> [T] {
        return Array(contents[pages[i]])
    }
    
    public func indexes(forPage i: Int) -> CountableRange<Int> {
        return pages[i]
    }
}

// MARK: -

extension PaginatedList: RandomAccessCollection {
    
    // MARK: - RandomAccessCollection
    
    public var startIndex: Int {
        return contents.startIndex
    }
    
    public var endIndex: Int {
        return contents.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return contents.index(after: i)
    }
    
    public subscript(index: Int) -> T {
        return contents[index]
    }
}

// MARK: -

enum PaginatedListError: Error {
    
    // MARK: - Errors
    
    case initialPageIndexNotZero(Int)
    case wrongNextPageIndex(Int, expected: Int)
}

// MARK: -

extension Error {
    
    // MARK: -
    
    var isPaginationRelated: Bool {
        return self is PaginatedListError
    }
}
