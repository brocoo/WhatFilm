//
//  Reactive+UIView.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/14/19.
//  Copyright © 2019 Julien Ducret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    
    // MARK: - UIScrollView reactive extension
    
    public var bounds: Observable<CGRect> {
        return observe(CGRect.self, "bounds").flatMap { Observable.from(optional: $0) }
    }
}
