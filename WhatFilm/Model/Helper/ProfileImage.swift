//
//  ProfileImage.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/20/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

struct ProfileImage: Decodable {
    
    // MARK: - Properties
    
    let filePath: String
    
    // MARK: - Keys
    
    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }

    // MARK: - Initializer
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filePath = try container.decode(String.self, forKey: .filePath)
    }
}
