//
//  FilmCredit.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class FilmCredited: Film {

    // MARK: - Properties
    
    let category: PersonCategory?
    
    // MARK: - Initializer
    
    public required init(from decoder: Decoder) throws {
        self.category = try PersonCategory(from: decoder)
        try super.init(from: decoder)
    }
}
