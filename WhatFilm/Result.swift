////
////  Result.swift
////  WhatFilm
////
////  Created by Julien Ducret on 13/09/2016.
////  Copyright © 2016 Julien Ducret. All rights reserved.
////
//
//import Foundation
//import RxSwift
//
///**
// Enum representing the result of an operation or request, if successful, a value of any type is available, if not, it contains an ErrorType
// 
// - Success: The operation has been successful, an associated value of the expected type is available.
// 
// - Failure: An error occured, an ErrorType conforming object or struct is associated to this case.
// */
//
//public enum Result<T> {
//    
//    case success(T)
//    case failure(Error)
//    
//    public init(_ value: T) {
//        self = .success(value)
//    }
//    
//    public init(_ error: Error) {
//        self = .failure(error)
//    }
//    
//    public var value: T? {
//        switch self {
//        case .success(let value): return value
//        case .failure(_): return nil
//        }
//    }
//    
//    public var error: Error? {
//        switch self {
//        case .success(_): return nil
//        case .failure(let error): return error
//        }
//    }
//    
//    public var successful: Bool {
//        switch self {
//        case .success(_): return true
//        case .failure(_): return false
//        }
//    }
//    
//    public var failed: Bool { return !self.successful }
//}
//
//extension Result {
//    
//    // MARK: - Map
//    
//    func map<U>(_ f: (T) -> U) -> Result<U> {
//        switch self {
//        case .success(let value): return Result<U>.success(f(value))
//        case .failure(let error): return Result<U>.failure(error)
//        }
//    }
//    
//    func map<U>(_ f: (T) throws -> U) -> Result<U> {
//        switch self {
//        case .success(let value):
//            do {
//                let newValue = try f(value)
//                return Result<U>.success(newValue)
//            } catch {
//                return Result<U>.failure(error)
//            }
//        case .failure(let error): return Result<U>.failure(error)
//        }
//    }
//}
//
//extension Result {
//    
//    // MARK: - Flatten & flatMap
//    
//    static func flatten<T>(_ result: Result<Result<T>>) -> Result<T> {
//        switch result {
//        case .success(let innerResult): return innerResult
//        case .failure(let error): return Result<T>.failure(error)
//        }
//    }
//    
//    func flatMap<U>(_ f: (T) -> Result<U>) -> Result<U> {
//        return Result.flatten(self.map(f))
//    }
//}
//
//extension Result: CustomStringConvertible {
//    
//    // MARK: - CustomStringConvertible
//    
//    public var description: String {
//        switch self {
//        case .success(let value):
//            guard let descriptable = value as? CustomStringConvertible else { return "\(value)" }
//            return descriptable.description
//        case .failure(_): return "Error"
//        }
//    }
//}
//
//extension Result {
//    
//    public func onObserver(_ observer: AnyObserver<T>) {
//        switch self {
//        case .success(let value):
//            observer.onNext(value)
//            observer.onCompleted()
//        case .failure(let error):
//            observer.onError(error)
//        }
//    }
//}
