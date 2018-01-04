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
        TMDbAPI.instance.start()
        Fabric.with([Crashlytics.self])
    }
    
    static func setupAppearance() {
        
        // Tint colors
        UIApplication.shared.delegate?.window??.tintColor = UIColor(commonColor: .yellow)
        UIRefreshControl.appearance().tintColor = UIColor(commonColor: .yellow)
        UITabBar.appearance().barTintColor = UIColor(commonColor: .offBlack)
        
        // Global font
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: TextStyle.navigationTitle.font]
        UILabel.appearance().font = TextStyle.body.font
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: TextStyle.body.font], for: .normal)
        
        // UINavigation bar
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
    }
}
