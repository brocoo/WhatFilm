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

public final class SearchViewModel {
    
    // MARK: - Properties
    
    let disposaBag: DisposeBag = DisposeBag()
    
    // MARK: - Input properties
    
    let textSearchTrigger: PublishSubject<String> = PublishSubject()
    let nextPageTrigger: PublishSubject<Void> = PublishSubject()
    
    // MARK: - UI Drivers
    
    lazy private(set) var filmsTask: Driver<Task<[Film]>> = makeFilmsTask()
    lazy private(set) var films = filmsTask.map { $0.result?.value ?? [] }
    
    // MARK: - Initializer
    
    init() { }
    
    // MARK: - Reactive Setup
    
    fileprivate func makeFilmsTask() -> Driver<Task<[Film]>> {
        
        let trigger = nextPageTrigger.asObservable().debounce(0.2, scheduler: MainScheduler.instance)
        
        return textSearchTrigger
            .asObservable()
            .distinctUntilChanged()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { (query) -> Observable<Task<[Film]>> in
                
                Analytics.track(searchQuery: query)
                return Observable.concat([
                    Observable.just(Task.loading),
                    TMDbAPI.instance.films(withTitle: query, loadNextPageTrigger: trigger).asTask()
                    ])
                
            }.asDriver(onErrorJustReturn: Task(GeneralError.default))
    }
}
