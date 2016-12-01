//
//  PersonDetail.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import SwiftyJSON
import DateTools

public final class PersonDetail: NSObject, JSONInitializable {
    
    // MARK: - Properties
    
    let id: Int
    let name: String
    let profilePathString: String?
    let biography: String
    let birthdate: Date?
    let deathDate: Date?
    let placeOfBirth: String?
    let imagesPathStrings: [String]
    
    // MARK: - Computed properties
    
    var profilePath: ImagePath? {
        guard let profilePathString = self.profilePathString else { return nil }
        return ImagePath.profile(path: profilePathString)
    }
    
    var initials: String {
        let components: [String] = self.name.components(separatedBy: " ")
        let size = min(components.count, 3)
        return components[0..<size].reduce("") { (aggregate, subname) -> String in
            guard subname.characters.count > 0 else { return "" }
            return aggregate + String(subname.characters.prefix(1))
        }
    }
    
    var age: Int? {
        guard let birthdate = self.birthdate else { return nil }
        let endDate = self.deathDate ?? Date()
        return (endDate as NSDate).years(from: birthdate)
    }
    
    // MARK: - Initializer (JSONInitializable)
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.profilePathString = json["profile_path"].string
        self.biography = json["biography"].stringValue
        self.birthdate = json["birthday"].date
        self.deathDate = json["deathday"].date
        self.placeOfBirth = json["place_of_birth"].string
        self.imagesPathStrings = json["images"]["profiles"].arrayValue.flatMap({ $0.string })
        super.init()
    }
}
