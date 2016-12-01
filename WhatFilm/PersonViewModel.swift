//
//  PersonViewModel.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PersonViewModel: NSObject {
    
    // MARK: - Properties
    
    let personDetail: Observable<PersonDetail>
    let filmsCredits: Observable<FilmsCredited>
    
    // MARK: - Initializer
    
    init(withPersonId id: Int) {
        
        self.personDetail = Observable
            .just(())
            .flatMapLatest { _ in
                return TMDbAPI.instance.person(forId: id)
            }.shareReplay(1)
        
        
        self.filmsCredits = Observable
            .just(())
            .flatMapLatest { _ in
                return TMDbAPI.instance.filmsCredited(forPersonId: id)
            }.shareReplay(1)
        
        super.init()
    }
}
