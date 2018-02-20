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

final class PersonViewModel {
    
    // MARK: - UI Drivers
    
    lazy private(set) var personDetail = makePersonDetailDriver()
    lazy private(set) var filmsCredits = makePersonFilmsCredit()
    
    // MARK: - Properties
    
    private let personId: Int
    
    // MARK: - Initializer
    
    init(withPersonId id: Int) {
        self.personId = id
    }
    
    // MARK: -
    
    private func makePersonDetailDriver() -> Driver<Result<PersonDetail>> {
        return Observable
            .just(())
            .flatMapLatest { TMDbAPI.instance.person(forId: self.personId) }
            .asResult()
            .asDriver(onErrorJustReturn: Result(GeneralError.default))
    }
    
    private func makePersonFilmsCredit() -> Driver<Result<PersonCreditedFilms>> {
        return Observable
            .just(())
            .flatMapLatest { TMDbAPI.instance.filmsCredited(forPersonId: self.personId) }
            .asResult()
            .asDriver(onErrorJustReturn: Result(GeneralError.default))
    }
}
