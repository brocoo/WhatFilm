//
//  DateManager.swift
//  WhatFilm
//
//  Created by Julien Ducret on 13/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

// MARK: - Date format

enum DateFormat: String {
    
    case iso8601 = "yyyy-MM-dd"
    case year = "yyyy"
}

// MARK: -

public final class DateManager: NSObject {
    
    // MARK: - Properties
    
    private var dateFormatters: [DateFormat: DateFormatter] = [:]
    
    fileprivate static var shared: DateManager = DateManager()
    fileprivate var calendar = Calendar.current
    
    // MARK: - Initializer

    fileprivate override init() { super.init() }
    
    // MARK: - Private functions
    
    private func dateFormatter(for format: DateFormat) -> DateFormatter {
        if let dateFormatter = dateFormatters[format] { return dateFormatter }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format.rawValue
            dateFormatters[format] = dateFormatter
            return dateFormatter
        }
    }
    
    // MARK: - Helper functions
    
    fileprivate func string(from date: Date, withFormat format: DateFormat) -> String {
        return dateFormatter(for: format).string(from: date)
    }
    
    fileprivate func date(from string: String, withFormat format: DateFormat) -> Date? {
        return dateFormatter(for: format).date(from: string)
    }
}

// MARK: -

extension Date {
    
    // MARK: -
    
    func asString(withFormat format: DateFormat) -> String {
        return DateManager.shared.string(from: self, withFormat: format)
    }
    
    func age(upTo endDate: Date) -> Int? {
        return DateManager.shared.calendar.dateComponents([.year], from: self, to: endDate).year
    }
}

// MARK: -

extension String {
    
    // MARK: -
    
    func asDate(withFormat format: DateFormat) -> Date? {
        return DateManager.shared.date(from: self, withFormat: format)
    }
}
