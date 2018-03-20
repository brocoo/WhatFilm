//
//  ResponseProtocol.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/14/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

protocol ResponseProtocol: CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: - Properties
    
    var request: RequestProtocol { get }
    var data: Result<Data> { get }
    
    // MARK: - Initializer
    
    init(request: RequestProtocol, data: Result<Data>)
}

// MARK: -

extension ResponseProtocol {
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        switch self.data {
        case .success: return "[RESPONSE PROTOCOL] ✅ SUCCESSFUL \(request.path)"
        case .failure(let error): return "[RESPONSE PROTOCOL] ❌ FAILURE \(request.path)\n\(error)"
        }
    }
    
    var debugDescription: String { return description }
}

