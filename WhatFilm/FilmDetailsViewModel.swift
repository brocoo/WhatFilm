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
    
    private let film: Film
//    lazy private(set) var films: Observable<FilmDetail> = Observable()
    
    // MARK: - Initializer
    
    init(withFilm film: Film) {
        self.film = film
        super.init()
    }
    
    // MARK: - Reactive setup
}
