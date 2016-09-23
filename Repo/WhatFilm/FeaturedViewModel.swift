//
//  FeaturedViewModel.swift
//  WhatFilm
//
//  Created by Julien Ducret on 23/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

final class FeaturedViewModel: NSObject {
    
    // MARK: - Properties
    
    let disposaBag: DisposeBag = DisposeBag()
    
    // Input
    let reloadTrigger: PublishSubject<Void> = PublishSubject()
    let nextPageTrigger: PublishSubject<Void> = PublishSubject()
    
    // Output
    lazy private(set) var films: Observable<[Film]> = self.setupFilms()
    
    // MARK: - Reactive Setup
    
    fileprivate func setupFilms() -> Observable<[Film]> {
        
        let trigger = self.nextPageTrigger.asObservable().debounce(0.2, scheduler: MainScheduler.instance)
        
        return self.reloadTrigger
            .asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { (_) -> Observable<[Film]> in
                return TMDbAPI.popularFilms(startingAtPage: 0, loadNextPageTrigger: trigger)
            }
            .shareReplay(1)
    }

}
