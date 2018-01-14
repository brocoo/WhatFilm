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

public final class SearchViewModel: NSObject {
    
    // MARK: - Properties
    
    let disposaBag: DisposeBag = DisposeBag()
    
    // Input
    let textSearchTrigger: PublishSubject<String> = PublishSubject()
    let nextPageTrigger: PublishSubject<Void> = PublishSubject()
    
    // Output
    lazy private(set) var films: Observable<[Film]> = self.setupFilms()
    lazy private(set) var isLoading: PublishSubject<Bool> = PublishSubject()
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        self.setupIsLoading()
    }
    
    // MARK: - Reactive Setup
    
    fileprivate func setupIsLoading() {
        self.films
            .subscribe(onNext: { [weak self] (films) in
                self?.isLoading.on(.next(false))
            }, onError: { [weak self] (error) in
                self?.isLoading.on(.next(false))
            }, onCompleted: { [weak self] in
                self?.isLoading.on(.next(false))
            }, onDisposed: { [weak self] in
                self?.isLoading.on(.next(false))
            }).disposed(by: self.disposaBag)
    }
    
    fileprivate func setupFilms() -> Observable<[Film]> {
        
        let trigger = self.nextPageTrigger.asObservable().debounce(0.2, scheduler: MainScheduler.instance)
        
        return self.textSearchTrigger
            .asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] (query) -> Observable<[Film]> in
                Analytics.track(searchQuery: query)
                self?.isLoading.on(.next(true))
                return TMDbAPI.instance.films(withTitle: query, loadNextPageTrigger: trigger)
            }
            .share(replay: 1)
    }
}
