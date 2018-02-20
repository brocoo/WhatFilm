//
//  RequestBody.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/14/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

public enum RequestBody {
    
    // MARK: - Cases
    
    case json(parameters: [String: Any])
    case base64(data: Data)
    
    // MARK: - Properties
    
    var data: Data? {
        switch self {
        case .json(let parameters):
            do {
                return try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                return nil
            }
        case .base64(let data):
            return data.base64EncodedString().data(using: .utf8)
        }
    }
    
    var contentType: String {
        switch self {
        case .json: return "application/json"
        case .base64: return "text/plain"
        }
    }
}
