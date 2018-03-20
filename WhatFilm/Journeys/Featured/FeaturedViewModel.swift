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

final class FeaturedViewModel {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    
    // MARK: - Reactive triggers (input)
    
    let reloadTrigger: PublishSubject<Void> = PublishSubject()
    let nextPageTrigger: PublishSubject<Void> = PublishSubject()
    
    // MARK: - Reactive drivers (output)
    
    lazy private(set) var filmsTask = makeFilmsDriver()
    
    // MARK: - Initializer
    
    init() { }
    
    // MARK: - Reactive Setup
    
    fileprivate func makeFilmsDriver() -> Driver<Task<PaginatedList<Film>>> {
        
        let nextPage = nextPageTrigger.debounce(0.2, scheduler: MainScheduler.instance)
        
        let sequence = Observable.concat([
            Observable.just(Task.loading),
            TMDbAPI.instance.popularFilms(startingAtPage: 0, loadNextPageTrigger: nextPage).asTask()
            ])
        
        return reloadTrigger
            .debounce(0.3, scheduler: MainScheduler.instance)
            .flatMap { sequence }
            .asDriver(onErrorJustReturn: Task(GeneralError.default))
    }
}
