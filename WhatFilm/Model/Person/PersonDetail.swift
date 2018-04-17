//
//  PersonDetail.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

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
    
    var age: Int? { return birthDate?.age(upTo: deathDate ?? Date()) }
    
    var birthDeathYearsAndAgeFormatted: String? {
        guard let birthYearString = birthDate?.asString(withFormat: .year) else { return nil }
        guard let age = age else { return birthYearString }
        guard let deathYearString = deathDate?.asString(withFormat: .year) else { return birthYearString + " (\(age))" }
        return birthYearString + " - " + deathYearString + " (\(age))"
    }
    
    // MARK: - Lazy properties
    
    lazy private(set) var initials: String = { return name.initials(upTo: 3) }()
    
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
        case birthDate = "birthday"
        case deathDate = "deathday"
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
        let birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)?.asDate(withFormat: .iso8601)
        let deathDate = try container.decodeIfPresent(String.self, forKey: .deathDate)?.asDate(withFormat: .iso8601)
        let placeOfBirth = try container.decodeIfPresent(String.self, forKey: .placeOfBirth)
        let imagesContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .images)
        let imagesPathStrings = try imagesContainer.decode([ProfileImage].self, forKey: .profiles).map { $0.filePath }
        self.init(id: id, name: name, profilePathString: profilePathString, biography: biography, birthDate: birthDate, deathDate: deathDate, placeOfBirth: placeOfBirth, imagesPathStrings: imagesPathStrings)
    }
}
