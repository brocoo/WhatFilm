//
//  Reactive+UIViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 3/27/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    
    // MARK: - UIViewController reactive extension
    
    public var viewDidLoad: Driver<Void> {
        return sentMessage(#selector(UIViewController.viewDidLoad))
            .asDriver(onErrorJustReturn: [])
            .map { _ in return () }
    }
    
    public var viewWillAppear: Driver<Bool> {
        return sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .asDriver(onErrorJustReturn: [])
            .flatMap { Driver.from(optional: $0.first as? Bool) }
    }
    
    public var viewDidAppear: Driver<Bool> {
        return sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .asDriver(onErrorJustReturn: [])
            .flatMap { Driver.from(optional: $0.first as? Bool) }
    }
    
    public var viewWillDisappear: Driver<Bool> {
        return sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
            .asDriver(onErrorJustReturn: [])
            .flatMap { Driver.from(optional: $0.first as? Bool) }
    }
    
    public var viewDidDisappear: Driver<Bool> {
        return sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .asDriver(onErrorJustReturn: [])
            .flatMap { Driver.from(optional: $0.first as? Bool) }
    }
}
