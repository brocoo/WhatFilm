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
    
    let film: Observable<Film>
    let filmDetail: Observable<FilmDetail>
    
    // MARK: - Initializer
    
    init(withFilm film: Film) {
        
        self.film = Observable
            .just(film)
            .shareReplay(1)
        
        self.filmDetail = Observable
            .just(())
            .flatMapLatest { (_) -> Observable<FilmDetail> in
                return TMDbAPI.filmDetail(fromId: film.id)
            }.shareReplay(1)
        
        super.init()
    }
}
