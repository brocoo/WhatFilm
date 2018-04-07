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
    private let tmdbAPI: TMDbAPI
    
    // MARK: - Reactive triggers (input)

    let textSearchTrigger: PublishSubject<String> = PublishSubject()
    let nextPageTrigger: PublishSubject<Void> = PublishSubject()
    
    // MARK: - Reactive drivers (output)

    lazy private(set) var filmsTask = makeFilmsTask()
    lazy private(set) var films = filmsTask.map { $0.result?.value ?? PaginatedList.empty }
    
    // MARK: - Initializer
    
    init(tmdbAPI: TMDbAPI) {
        self.tmdbAPI = tmdbAPI
    }

    // MARK: - Reactive Setup
    
    fileprivate func makeFilmsTask() -> Driver<Task<PaginatedList<Film>>> {
        
        let trigger = nextPageTrigger.asObservable().debounce(0.2, scheduler: MainScheduler.instance)
        
        return textSearchTrigger
            .asObservable()
            .distinctUntilChanged()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { (query) -> Observable<Task<PaginatedList<Film>>> in
                
                Analytics.track(searchQuery: query)
                return Observable.concat([
                    Observable.just(Task.loading),
                    self.tmdbAPI.films(withTitle: query, loadNextPageTrigger: trigger).asTask()
                    ])
                
            }.asDriver(onErrorJustReturn: Task(GeneralError.default))
    }
}
