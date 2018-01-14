//
//  DateManager.swift
//  WhatFilm
//
//  Created by Julien Ducret on 13/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class DateManager: NSObject {
    
    // MARK: - Properties
    
    static var SharedFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: - Initializer

    fileprivate override init() { super.init() } 
}
