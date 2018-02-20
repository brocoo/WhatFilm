//
//  FilmDetailsViewModel.swift
//  WhatFilm
//
//  Created by Julien Ducret on 28/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public final class FilmDetailsViewModel {

    // MARK: - Properties
    
    private let filmId: Int
    
    // MARK: - Reactive drivers (output)

    private(set) lazy var filmDetail = makeFilmDetails()
    private(set) lazy var credits = makeCredits()
    
    // MARK: - Initializer
    
    init(withFilmId id: Int) {
        self.filmId = id
    }
    
    // MARK: -
    
    fileprivate func makeFilmDetails() -> Driver<Result<FilmDetail>> {
        return Observable
            .just(())
            .flatMapLatest { TMDbAPI.instance.filmDetail(fromId: self.filmId) }
            .asResult()
            .asDriver(onErrorJustReturn: Result(GeneralError.default))
    }
    
    fileprivate func makeCredits() -> Driver<Result<FilmCredits>> {
        return Observable
            .just(())
            .flatMapLatest { TMDbAPI.instance.credits(forFilmId: self.filmId) }
            .asResult()
            .asDriver(onErrorJustReturn: Result(GeneralError.default))
    }
}
