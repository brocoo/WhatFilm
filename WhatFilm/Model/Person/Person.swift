//
//  Person.swift
//  WhatFilm
//
//  Created by Julien Ducret on 06/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

// MARK: -

public enum PersonCategory {
    
    case cast(character: String)
    case crew(job: String)
}

// MARK: -

extension PersonCategory: Decodable {
    
    // MARK: - Keys
    
    enum CodingKeys: String, CodingKey {
        case character
        case job
    }
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.character) {
            let character = try container.decode(String.self, forKey: .character)
            self = .cast(character: character)
        } else if container.contains(.job) {
            let job = try container.decode(String.self, forKey: .job)
            self = .crew(job: job)
        } else {
            let keys = [CodingKeys.character, CodingKeys.job]
            let debugDescription = "Expected PersonCategory object"
            let context = DecodingError.Context(codingPath: keys, debugDescription: debugDescription)
            throw DecodingError.typeMismatch(PersonCategory.self, context)
        }
    }
}

// MARK: -

public final class Person {

    // MARK: - Properties
    
    let id: Int
    let name: String
    let category: PersonCategory
    let profilePathString: String?
    
    // MARK: - Computed properties
    
    var profilePath: ImagePath? {
        guard let profilePathString = self.profilePathString else { return nil }
        return ImagePath.profile(path: profilePathString)
    }
    
    var initials: String { return name.initials(upTo: 3) }
    
    var role: String {
        switch self.category {
        case .cast(let character): return character
        case .crew(let job): return job
        }
    }
    
    // MARK: - Initializer
    
    init(id: Int, name: String, category: PersonCategory, profilePathString: String?) {
        self.id = id
        self.name = name
        self.category = category
        self.profilePathString = profilePathString
    }
}

extension Person: Decodable {
    
    // MARK: - Keys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
    }
    
    // MARK: - Initializer
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let category = try PersonCategory(from: decoder)
        let profilePathString = try container.decodeIfPresent(String.self, forKey: .profilePath)
        self.init(id: id, name: name, category: category, profilePathString: profilePathString)
    }
}
