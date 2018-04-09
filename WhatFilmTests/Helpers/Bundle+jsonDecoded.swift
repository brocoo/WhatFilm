//
//  Bundle+jsonDecoded.swift
//  WhatFilmTests
//
//  Created by Julien Ducret on 4/8/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import XCTest
import Foundation

enum BundleError: Error {
    case urlError(forResource: String, withExtension: String?)
}

extension Bundle {
    
    // MARK: -
    
    func data(forResource ressource: String, withExtension fileExtension: String? = nil) throws -> Data {
        guard let url = url(forResource: ressource, withExtension: fileExtension) else {
            throw BundleError.urlError(forResource: ressource, withExtension: fileExtension)
        }
        return try Data(contentsOf: url)
    }
    
    func jsonDecoded<T: Decodable>(forResource ressource: String, withExtension fileExtension: String? = nil) throws -> T {
        let jsonData = try data(forResource: ressource, withExtension: fileExtension)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}

extension XCTestCase {
    
    // MARK: -
    
    func data(forResource ressource: String, withExtension fileExtension: String? = nil) throws -> Data {
        return try Bundle(for: type(of: self)).data(forResource: ressource, withExtension: fileExtension)
    }
    
    func jsonDecoded<T: Decodable>(forResource ressource: String, withExtension fileExtension: String? = nil) throws -> T {
        return try Bundle(for: type(of: self)).jsonDecoded(forResource: ressource, withExtension: fileExtension)
    }
}
