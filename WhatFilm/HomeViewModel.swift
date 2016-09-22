//
//  HomeDataController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 13/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

public final class HomeViewModel: NSObject {
    
    // MARK: - Properties
    
    let disposaBag: DisposeBag = DisposeBag()
    
    // Input
    let textSearchTrigger: PublishSubject<String> = PublishSubject()
    let nextPageTrigger: PublishSubject<Void> = PublishSubject()
    
    // Output
    lazy private(set) var films: Observable<[Film]> = self.setupFilms()
    
    // MARK: - Reactive Setup
    
    fileprivate func setupFilms() -> Observable<[Film]> {
        
        let trigger = self.nextPageTrigger.asObservable().debounce(0.2, scheduler: MainScheduler.instance)
        
        return self.textSearchTrigger
            .asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { (query) -> Observable<[Film]> in
                return TMDbAPI.films(withTitle: query, loadNextPageTrigger: trigger)
            }
            .shareReplay(1)
    }
}
