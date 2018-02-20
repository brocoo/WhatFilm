//
//  ResponseProtocol.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/14/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

protocol ResponseProtocol {
    
    // MARK: - Properties
    
    var request: RequestProtocol { get }
    var data: Result<Data> { get }
    
    // MARK: - Initializer
    
    init(request: RequestProtocol, data: Result<Data>)
}
