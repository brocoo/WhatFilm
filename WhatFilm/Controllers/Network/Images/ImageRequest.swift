//
//  ImageRequest.swift
//  WhatFilm
//
//  Created by Julien Ducret on 4/26/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

enum ImageRequestError: Error {
    
    case invalidBaseURL(String)
}

struct ImageRequest: RequestProtocol {
    
    // MARK: - Properties
    
    let scheme: String?
    let host: String?
    let path: String
    let method: RequestMethod = .get
    let body: RequestBody? = nil
    let headers: [String: String] = ["Accept": "image/png"]
    let parameters: [URLParameter] = []
    
    // MARK: - Initializer
    
    init(baseUrlString: String, path: String) throws {
        guard let url = URL(string: baseUrlString), let scheme = url.scheme, let host = url.host else {
            throw ImageRequestError.invalidBaseURL(baseUrlString)
        }
        self.scheme = scheme
        self.host = host
        self.path = [url.path, path].joined(separator: "/")
    }
}
