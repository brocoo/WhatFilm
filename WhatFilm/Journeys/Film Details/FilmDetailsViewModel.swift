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

public final class FilmDetailsViewModel: NSObject {

    // MARK: - Properties
    
    let filmId: Int
    let filmDetail: Observable<FilmDetail>
    let credits: Observable<FilmCredits>
    
    // MARK: - Initializer
    
    init(withFilmId id: Int) {
        self.filmId = id
        
        self.filmDetail = Observable
            .just(())
            .flatMapLatest { (_) -> Observable<FilmDetail> in
                return TMDbAPI.instance.filmDetail(fromId: id)
            }.share(replay: 1)
        
        
        self.credits = Observable
            .just(())
            .flatMapLatest { (_) -> Observable<FilmCredits> in
                return TMDbAPI.instance.credits(forFilmId: id)
            }.share(replay: 1)
        
        super.init()
    }
}
