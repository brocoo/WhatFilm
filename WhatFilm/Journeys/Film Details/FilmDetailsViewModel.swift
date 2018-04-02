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
    
    let film: Film
    
    // MARK: - Reactive drivers (output)

    private(set) lazy var filmDetail = makeFilmDetails()
    private(set) lazy var credits = makeCredits()
    
    // MARK: - Initializer
    
    init(withFilm film: Film) {
        self.film = film
    }
    
    // MARK: -
    
    fileprivate func makeFilmDetails() -> Driver<Result<FilmDetail>> {
        return Observable
            .just(())
            .flatMapLatest { TMDbAPI.instance.filmDetail(fromId: self.film.id) }
            .asResult()
            .asDriver(onErrorJustReturn: Result(GeneralError.default))
    }
    
    fileprivate func makeCredits() -> Driver<Result<FilmCredits>> {
        return Observable
            .just(())
            .flatMapLatest { TMDbAPI.instance.credits(forFilmId: self.film.id) }
            .asResult()
            .asDriver(onErrorJustReturn: Result(GeneralError.default))
    }
}
