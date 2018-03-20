//
//  Reactive+UIScrollView.swift
//  WhatFilm
//
//  Created by Julien Ducret on 3/20/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    // MARK: - UIScrollView reactive extension
    
    public var reachedBottom: Observable<Void> {
        return contentOffset
            .flatMap { [unowned base] (contentOffset) -> Observable<Void> in
                let visibleHeight = base.frame.height - base.contentInset.top - base.contentInset.bottom
                let y = contentOffset.y + base.contentInset.top
                let threshold = max(0.0, base.contentSize.height - visibleHeight)
                return (y > threshold) ? Observable.just(()) : Observable.empty()
        }
    }
    
    public var startedDragging: Observable<Void> {
        return base.panGestureRecognizer.rx
            .event
            .filter({ $0.state == .began })
            .map({ _ in () })
    }
}
