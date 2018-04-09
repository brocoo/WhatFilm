//
//  FilmTests.swift
//  WhatFilmTests
//
//  Created by Julien Ducret on 4/9/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import XCTest
@testable import WhatFilm

fileprivate let validFilmJsonString =
"""
{
"vote_count": 851,
"id": 338970,
"video": false,
"vote_average": 6.1,
"title": "Tomb Raider",
"popularity": 139.161412,
"poster_path": "/ePyN2nX9t8SOl70eRW47Q29zUFO.jpg",
"original_language": "en",
"original_title": "Tomb Raider",
"genre_ids": [
28,
12
],
"backdrop_path": "/yVlaVnGRwJMxB3txxwA24XurSNp.jpg",
"adult": false,
"overview": "Lara Croft, the fiercely independent daughter of a missing adventurer, must push herself beyond her limits when she finds herself on the island where her father disappeared.",
"release_date": "2018-03-08"
}
"""

fileprivate let invalidFilmJsonString =
"""
{
"vote_count": 851,
"video": false,
"vote_average": 6.1,
"title": "Tomb Raider",
"popularity": 139.161412,
"poster_path": "/ePyN2nX9t8SOl70eRW47Q29zUFO.jpg",
"original_language": "en",
"original_title": "Tomb Raider",
"genre_ids": [
28,
12
],
"backdrop_path": "/yVlaVnGRwJMxB3txxwA24XurSNp.jpg",
"adult": false,
"overview": "Lara Croft, the fiercely independent daughter of a missing adventurer, must push herself beyond her limits when she finds herself on the island where her father disappeared.",
"release_date": "2018-03-08"
}
"""

final class FilmTests: XCTestCase {
    
    func testProperties() { 
        
        guard
            let jsonData = validFilmJsonString.data(using: .utf8),
            let film = try? JSONDecoder().decode(Film.self, from: jsonData) else {
                XCTFail()
                return
        }
        
        XCTAssert(film.voteCount == 851)
        XCTAssert(film.id == 338970)
        XCTAssert(film.video == false)
        XCTAssert(film.voteAverage == 6.1)
        XCTAssert(film.title == "Tomb Raider")
        XCTAssert(film.genreIds == [28, 12])
        XCTAssert(film.backdropPathString == "/yVlaVnGRwJMxB3txxwA24XurSNp.jpg")
        XCTAssert(film.adult == false)
        XCTAssert(film.overview == "Lara Croft, the fiercely independent daughter of a missing adventurer, must push herself beyond her limits when she finds herself on the island where her father disappeared.")
        XCTAssert(film.releaseDate == Date(timeIntervalSince1970: 1520467200))
        XCTAssert(film.fullTitle == "Tomb Raider (2018)")
    }
    
    func testFailingInitialization() {
        
        guard let jsonData = invalidFilmJsonString.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        XCTAssertThrowsError(try JSONDecoder().decode(Film.self, from: jsonData))
    }
}
