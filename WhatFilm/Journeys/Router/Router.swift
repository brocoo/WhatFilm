//
//  Router.swift
//  WhatFilm
//
//  Created by Julien Ducret on 3/29/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class Router: NSObject {
    
    // MARK: - Enum
    
    enum TabBarRootItem: Int {
        case featured = 0
        case search
        case about
    }
    
    // MARK: - Properties
    
    private let tmdbAPI: TMDbAPI
    lazy fileprivate var tabBarController = self.setupTabBarController()
    
    // MARK: - Initializer
    
    init(tmdbAPI: TMDbAPI) {
        self.tmdbAPI = tmdbAPI
    }
    
    // MARK: - Setup navigation
    
    private func setupTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            FeaturedViewController(viewModel: FeaturedViewModel(tmdbAPI: tmdbAPI), router: self),
            SearchViewController(viewModel: SearchViewModel(tmdbAPI: tmdbAPI), router: self),
            AboutViewController(router: self)
        ].map { UINavigationController(rootViewController: $0) }
        tabBarController.tabBar.tintColor = UIColor(commonColor: .yellow)
        return tabBarController
    }
    
    func setup(`for` delegate: AppDelegate, with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        tmdbAPI.start(with: launchOptions)
        delegate.window = {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .white
            window.rootViewController = tabBarController
            return window
        }()
    }
    
    func tabBarItem(`for` rootItem: TabBarRootItem) -> UITabBarItem {
        switch rootItem {
        case .featured: return UITabBarItem(tabBarSystemItem: .featured, tag: rootItem.rawValue)
        case .search: return UITabBarItem(tabBarSystemItem: .search, tag: rootItem.rawValue)
        case .about: return UITabBarItem(title: "About", image: UIImage(named: "About_Icon"), tag: rootItem.rawValue)
        }
    }
    
    // MARK: - Routing functions
    
    func showFilmDetails(`for` film: Film, from viewController: UIViewController) {
        Analytics.track(viewContent: "Selected film", ofType: "Film", withId: "\(film.id)", withAttributes: ["Title": film.fullTitle])
        
        let viewModel = FilmDetailsViewModel(withFilm: film, tmdbAPI: tmdbAPI)
        let filmDetailsViewController = FilmDetailsViewController(viewModel: viewModel, router: self)
        
        viewController.navigationController?.delegate = self
        viewController.navigationController?.pushViewController(filmDetailsViewController, animated: true)
    }
    
    func showPerson(_ person: Person, backgroundImagePath path: Driver<ImagePath>, from viewController: UIViewController) {
        Analytics.track(viewContent: "Selected person", ofType: "Person", withId: "\(person.id)", withAttributes: ["Person": person.name])
        
        let viewModel = PersonViewModel(withPerson: person, tmdbAPI: tmdbAPI)
        let personViewController = PersonViewController(viewModel: viewModel, backgroundImagePath: path, router: self)
        
        viewController.navigationController?.delegate = self
        viewController.navigationController?.pushViewController(personViewController, animated: true)
    }
}

// MARK: -

extension Router: UINavigationControllerDelegate {
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch (operation, fromVC, toVC) {
        case (.push, _, toVC) where toVC is FilmDetailsViewController:
            guard let fromVC = fromVC as? (UIViewController & FilmDetailsTransitionable) else { return nil }
            return ToFilmDetailsTransitionAnimator(from: fromVC, destinationView: toVC.view)
        default: return nil
        }
    }
}
