//
//  DecodableResponse.swift
//  WhatFilm
//
//  Created by Julien Ducret on 2/4/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

class DecodableResponse<T: Decodable>: ResponseProtocol {
    
    // MARK: - ResponseProtocol properties
    
    let request: RequestProtocol
    let data: Result<Data>
    
    // MARK: - Properties
    
    lazy private(set) var decodedData: Result<T> = data.flatMap { Result<T>(jsonEncoded: $0) }
    
    // MARK: - Initializer
    
    required init(request: RequestProtocol, data: Result<Data>) {
        self.request = request
        self.data = data
    }
}
