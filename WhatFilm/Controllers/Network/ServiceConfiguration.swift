//
//  ServiceConfiguration.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/16/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

struct ServiceConfiguration {
    
    // MARK: - Properties
    
    let urlScheme: String
    let urlHost: String
    let defaultHTTPHeaders: [String: String]
    let defaultURLParameters: [URLParameter]
}
