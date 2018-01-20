//
//  PersonCreditedFilms.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/20/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

public struct PersonCreditedFilms: Decodable {
    
    // MARK: - Properties
    
    let id: Int
    let cast: [FilmCredited]
    let crew: [FilmCredited]
    
    // MARK: - Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case cast
        case crew
    }
}
