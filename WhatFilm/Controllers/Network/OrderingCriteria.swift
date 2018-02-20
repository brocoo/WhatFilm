//
//  OrderingCriteria.swift
//  WhatFilm
//
//  Created by Julien Ducret on 2/5/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

// MARK: - OrderingCriteria enum

public enum OrderingCriteria {
    
    // MARK: - Properties
    
    var stringPath: String {
        switch self {
        case .ascending: return ".asc"
        case .descending: return ".desc"
        }
    }
    
    // MARK: - Cases
    
    case ascending
    case descending
}
