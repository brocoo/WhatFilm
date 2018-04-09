//
//  PaginatedListTests.swift
//  WhatFilmTests
//
//  Created by Julien Ducret on 4/7/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import XCTest
@testable import WhatFilm

final class PaginatedListTests: XCTestCase {
    
    // MARK: - Properties
    
    lazy private var page1: Page<Film>? = try? jsonDecoded(forResource: "GET_movie_popular_1", withExtension: "json")
    lazy private var page2: Page<Film>? = try? jsonDecoded(forResource: "GET_movie_popular_2", withExtension: "json")
    
    // MARK: - Tests
    
    func testEmpty() {
        let emptyList: PaginatedList<Int> = PaginatedList.empty
        XCTAssert(emptyList.count == 0)
    }
    
    func testProperties() {
        guard let page1 = page1, let paginatedList = try? PaginatedList(with: page1) else {
            XCTFail()
            return
        }
        
        XCTAssert(paginatedList.count == 20)
        XCTAssert(paginatedList.hasMoreContent == true)
        XCTAssert(paginatedList.lastContentUpdate.isCreated)
        XCTAssert(paginatedList.contents(atPage: 0).count == 20)
    }
    
    func testAppendingPages() {
        guard let page1 = page1, let page2 = page2  else {
            XCTFail()
            return
        }

        var paginatedList: PaginatedList<Film> = PaginatedList.empty
        
        XCTAssertThrowsError(try paginatedList.append(page2))
        XCTAssertNoThrow(try paginatedList.append(page1))
        XCTAssertThrowsError(try paginatedList.append(page1))
        XCTAssert(paginatedList.count == 20)
        XCTAssert(paginatedList.hasMoreContent == true)
        XCTAssert(paginatedList.lastContentUpdate.isCreated)

        XCTAssertNoThrow(try paginatedList.append(page2))
        XCTAssertThrowsError(try paginatedList.append(page1))
        XCTAssertThrowsError(try paginatedList.append(page2))
        XCTAssert(paginatedList.count == 40)
        XCTAssert(paginatedList.hasMoreContent == true)
        if case let .newPageAdded(pageIndex) = paginatedList.lastContentUpdate {
            XCTAssert(pageIndex == 1)
        } else {
            XCTFail()
        }
    }
}

extension PaginatedList.Mutation {
    
    // MARK: -
    
    fileprivate var isCreated: Bool {
        guard case .created = self else { return false }
        return true
    }
}
