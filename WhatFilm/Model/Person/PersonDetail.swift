//
//  PersonDetail.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import DateTools

public final class PersonDetail {
    
    // MARK: - Properties
    
    let id: Int
    let name: String
    let profilePathString: String?
    let biography: String
    let birthDate: Date?
    let deathDate: Date?
    let placeOfBirth: String?
    let imagesPathStrings: [String]
    
    // MARK: - Computed properties
    
    var profilePath: ImagePath? {
        guard let profilePathString = self.profilePathString else { return nil }
        return ImagePath.profile(path: profilePathString)
    }
    
    var initials: String { return name.initials(upTo: 3) }
    
    var age: Int? {
        guard let birthdate = self.birthDate else { return nil }
        let endDate = self.deathDate ?? Date()
        return (endDate as NSDate).years(from: birthdate)
    }
    
    // MARK: - Initializer
    
    init(id: Int, name: String, profilePathString: String, biography: String, birthDate: Date?, deathDate: Date?, placeOfBirth: String?, imagesPathStrings: [String]) {
        self.id = id
        self.name = name
        self.profilePathString = profilePathString
        self.biography = biography
        self.birthDate = birthDate
        self.deathDate = deathDate
        self.placeOfBirth = placeOfBirth
        self.imagesPathStrings = imagesPathStrings
    }
}

// MARK: -

extension PersonDetail: Decodable {
    
    // MARK: - Keys
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case profilePathString = "profile_path"
        case biography
        case birthDate = "birthdate"
        case deathDate = "deathdate"
        case placeOfBirth = "place_of_birth"
        case images
        case profiles = "profiles"
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let profilePathString = try container.decode(String.self, forKey: .profilePathString)
        let biography = try container.decode(String.self, forKey: .biography)
        let birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)?.asISO8601Date
        let deathDate = try container.decodeIfPresent(String.self, forKey: .deathDate)?.asISO8601Date
        let placeOfBirth = try container.decodeIfPresent(String.self, forKey: .placeOfBirth)
        let imagesContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .images)
        let imagesPathStrings = try imagesContainer.decode([ProfileImage].self, forKey: .profiles).map { $0.filePath }
        self.init(id: id, name: name, profilePathString: profilePathString, biography: biography, birthDate: birthDate, deathDate: deathDate, placeOfBirth: placeOfBirth, imagesPathStrings: imagesPathStrings)
    }
}
