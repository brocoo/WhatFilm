//
//  Task.swift
//  WhatFilm
//
//  Created by Julien Ducret on 2/14/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation
import RxSwift

public enum Task<T> {
    
    // MARK: - Cases
    
    case loading
    case completed(Result<T>)
    
    // MARK: - Initializer
    
    init(_ value: T) {
        self = .completed(Result(value))
    }
    
    init(_ error: Error) {
        self = .completed(Result(error))
    }
}

// MARK: -

extension Task {
    
    // MARK: - Computed properties
    
    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }
    
    var result: Result<T>? {
        guard case let .completed(result) = self else { return nil }
        return result
    }
}

// MARK: -

extension ObservableType {
    
    // MARK: - Materialize as a task
    
    public func asTask() -> RxSwift.Observable<Task<Self.E>> {
        return asResult().map { Task.completed($0) }
    }
}
