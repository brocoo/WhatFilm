//
//  FilmCredit.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON

public typealias FilmsCredited = (asCast: [FilmCredited], asCrew: [FilmCredited])

public final class FilmCredited: Film {

    // MARK: - Properties
    
    let category: PersonCategory?
    
    // MARK: - Initializer
    
    public required init(json: JSON) {
        self.category = PersonCategory(json: json)
        super.init(json: json)
    }
}
