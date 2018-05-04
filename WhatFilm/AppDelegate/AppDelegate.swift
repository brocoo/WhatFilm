//
//  AppDelegate.swift
//  WhatFilm
//
//  Created by Julien Ducret on 07/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {
    
    // MARK: - Properties

    var window: UIWindow?
    fileprivate let api = TMDbAPI()
    fileprivate lazy var router = Router(tmdbAPI: api)
}

// MARK: -

extension AppDelegate: UIApplicationDelegate {
    
    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Settings.initializeServices()
        Settings.setupAppearance()
        UIImageView.api = api
        router.setup(for: self, with: launchOptions)
        window?.makeKeyAndVisible()
        return true
    }
}

