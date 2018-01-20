//
//  String+Tools.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/5/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

extension String {
    
    var initials: String {
        return components(separatedBy: " ").reduce("") { (string, nextWord) -> String in
            guard nextWord.count > 0 else { return string }
            return string + nextWord.prefix(1).uppercased()
        }
    }
    
    func initials(upTo maxLength: Int) -> String {
        return String(initials.prefix(maxLength))
    }
    
    var asISO8601Date: Date? {
        return DateManager.sharedFormatter.date(from: self)
    }
    
    var asURL: URL? {
        return URL(string: self)
    }
}
