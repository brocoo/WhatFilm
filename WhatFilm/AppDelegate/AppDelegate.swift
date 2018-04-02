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
    fileprivate lazy var router = Router()
}

// MARK: -

extension AppDelegate: UIApplicationDelegate {
    
    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Settings.initializeServices()
        Settings.setupAppearance()
        router.setup(for: self)
        window?.makeKeyAndVisible()
        return true
    }
}

