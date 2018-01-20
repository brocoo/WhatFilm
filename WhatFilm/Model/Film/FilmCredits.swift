//
//  FilmCredits.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/17/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

public struct FilmCredits: Decodable {
    
    // MARK: - Properties
    
    let cast: [Person]
    let crew: [Person]
}
