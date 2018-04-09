//
//  PageTests.swift
//  WhatFilmTests
//
//  Created by Julien Ducret on 4/7/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import XCTest
@testable import WhatFilm

final class PageTests: XCTestCase {
    
    // MARK: - Tests
    
    func testProperties() {
        
        let firstPageResults = Array(1...20)
        let lastPageResults = Array(21...40)
        
        let firstPage = Page(pageIndex: 0, totalResults: 40, totalPages: 2, results: firstPageResults)
        XCTAssert(firstPage.count == firstPageResults.count)
        XCTAssert(firstPage.pageIndex == 0)
        XCTAssert(firstPage.totalResults == 40)
        XCTAssert(firstPage.totalPages == 2)
        XCTAssert(firstPage.hasNextPage == true)
        XCTAssert(firstPage.nextPageIndex == 1)
        XCTAssert(firstPage.asArray == firstPageResults)
        firstPage.enumerated().forEach { XCTAssert($0.element == firstPageResults[$0.offset]) }
        
        let lastPage = Page(pageIndex: 1, totalResults: 40, totalPages: 2, results: lastPageResults)
        XCTAssert(lastPage.count == lastPageResults.count)
        XCTAssert(lastPage.pageIndex == 1)
        XCTAssert(lastPage.totalResults == 40)
        XCTAssert(lastPage.totalPages == 2)
        XCTAssert(lastPage.hasNextPage == false)
        XCTAssert(lastPage.nextPageIndex == 2)
        XCTAssert(lastPage.asArray == lastPageResults)
        lastPage.enumerated().forEach { XCTAssert($0.element == lastPageResults[$0.offset]) }
        
        let emptyPage: Page<Int> = Page(pageIndex: 0, totalResults: 0, totalPages: 0, results: [])
        XCTAssert(emptyPage.count == 0)
        XCTAssert(emptyPage.pageIndex == 0)
        XCTAssert(emptyPage.totalResults == 0)
        XCTAssert(emptyPage.totalPages == 0)
        XCTAssert(emptyPage.hasNextPage == false)
        XCTAssert(emptyPage.nextPageIndex == 1)
        XCTAssert(emptyPage.asArray == [])
    }
    
    func testJSONDecoderInitialization() {

        guard
            let jsonData = try? self.data(forResource: "GET_movie_popular_1", withExtension: "json"),
            let page: Page<Film> = try? JSONDecoder().decode(Page.self, from: jsonData) else {
                XCTFail()
                return
        }
        
        XCTAssert(page.count == 20)
        XCTAssert(page.pageIndex == 0)
        XCTAssert(page.totalResults == 19829)
        XCTAssert(page.totalPages == 992)
        XCTAssert(page.hasNextPage == true)
        XCTAssert(page.nextPageIndex == 1)
    }
}
