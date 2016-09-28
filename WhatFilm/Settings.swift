//
//  Settings.swift
//  WhatFilm
//
//  Created by Julien Ducret on 28/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

public struct Settings {
    
    // MARK: - Private initializer
    
    private init() {}
    
    // MARK: - Functions
    
    static func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    
    static func initializeServices() {
        TMDbAPI.start()
        Fabric.with([Crashlytics.self])
    }
    
    static func setupAppearance() {
        UIApplication.shared.delegate?.window??.tintColor = UIColor(commonColor: .yellow)
        UIRefreshControl.appearance().tintColor = UIColor(commonColor: .yellow)
        UITabBar.appearance().barTintColor = UIColor(commonColor: .offBlack)
    }
}