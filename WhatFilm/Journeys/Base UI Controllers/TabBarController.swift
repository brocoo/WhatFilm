//
//  TabBarViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 12/12/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class TabBarController: UITabBarController {

    // MARK: - UIViewController life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        if let aboutItem = self.tabBar.items?[2] {
            aboutItem.selectedImage = #imageLiteral(resourceName: "About_Icon").withRenderingMode(.alwaysTemplate)
            aboutItem.image = #imageLiteral(resourceName: "About_Icon").withRenderingMode(.alwaysTemplate)
        }
    }
}
