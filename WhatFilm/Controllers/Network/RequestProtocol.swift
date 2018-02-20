//
//  RequestProtocol.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/14/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

protocol RequestProtocol {
    
    // MARK: - Properties
    
    var path: String { get }
    var method: RequestMethod { get }
    var body: RequestBody? { get }
    var headers: [String: String] { get }
    var parameters: [URLParameter] { get }
}

// MARK: -

extension RequestProtocol {
    
    // MARK: - Default properties
    
    
}
