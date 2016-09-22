//
//  TMDbAPI.swift
//  WhatFilm
//
//  Created by Julien Ducret on 15/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import SwiftyJSON

final class TMDbAPI {
    
    // MARK: - singleton
    
    fileprivate static let instance: TMDbAPI = TMDbAPI()
    
    // MARK: - Initializer (private)
    
    fileprivate init() {}
    
    // MARK: - Configuration
    
//    static var apiConfiguration: Observable<APIConfiguration> { return TMDbAPI.instance.configuration }
//    
//    fileprivate var configuration: Observable<APIConfiguration> {
//        return Observable.create { (observer) -> Disposable in
//            let request = Alamofire
//                .request(Router.configuration)
//                .validate()
//                .responseJSON { (response) in
//                    switch response.result {
//                    case .success(let data):
//                        let json = JSON(data)
//                        
//                        
////                        observer.onNext(paginatedList)
////                        observer.onCompleted()
//                    case .failure(let error):
////                        observer.onError(error)
//                    }
//                }
//            return Disposables.create { request.cancel() }
//        }
//    }
    
    // MARK: - Search films
    
    class func films(withTitle title: String, startingAtPage page: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<[Film]> {
        let parameters: FilmSearchParameters = FilmSearchParameters(query: title, atPage: page)
        return TMDbAPI.instance.films(fromList: [], with: parameters, loadNextPageTrigger: trigger)
    }
    
    fileprivate func films(fromList currentList: [Film], with parameters: FilmSearchParameters, loadNextPageTrigger trigger: Observable<Void>) -> Observable<[Film]> {
        
        return self.films(with: parameters).flatMap { (paginatedList) -> Observable<[Film]> in
            let newList = currentList + paginatedList.results
            if let _ = paginatedList.nextPage {
                return [
                    Observable.just(newList),
                    Observable.never().takeUntil(trigger),
                    self.films(fromList: newList, with: parameters.nextPage, loadNextPageTrigger: trigger)
                ].concat()
            } else { return Observable.just(newList) }
        }
    }
    
    fileprivate func films(with parameters: FilmSearchParameters) -> Observable<PaginatedList<Film>> {
        guard !parameters.query.isEmpty else { return Observable.just(PaginatedList.Empty()) }
        return Observable<PaginatedList<Film>>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.searchFilms(parameters: parameters))
                .validate()
                .responsePaginatedFilms(queue: nil, completionHandler: { (response) in
                    switch response.result {
                    case .success(let paginatedList):
                        observer.onNext(paginatedList)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Popular films
    
    class func PopularFilms(atPage page: Int? = nil) -> Observable<PaginatedList<Film>> {
        return Observable<PaginatedList<Film>>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.popularFilms(page: page))
                .validate()
                .responsePaginatedFilms(queue: nil, completionHandler: { (response) in
                    switch response.result {
                    case .success(let paginatedList):
                        observer.onNext(paginatedList)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create { request.cancel() }
        }
    }
}

// MARK: -

extension Alamofire.DataRequest {
    
    static func filmsResponseSerializer() -> DataResponseSerializer<[Film]> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .success([]) }
                let jsonArray = JSON(data: data)["results"].arrayValue
                return .success(jsonArray.map({ Film(json: $0) }))
            }
        }
    }
    
    @discardableResult func responseFilms(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[Film]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.filmsResponseSerializer(), completionHandler: completionHandler)
    }
    
    static func paginatedFilmsResponseSerializer() -> DataResponseSerializer<PaginatedList<Film>> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .success(PaginatedList.Empty()) }
                let json = JSON(data: data)
                guard
                    let page = json["page"].int,
                    let totalResults = json["total_results"].int,
                    let totalPages = json["total_pages"].int else { return .success(PaginatedList.Empty()) }
                let films = json["results"].arrayValue.map({ Film(json: $0) })
                let paginatedList = PaginatedList(page: page - 1, totalResults: totalResults, totalPages: totalPages, results: films)
                return .success(paginatedList)
            }
        }
    }
    
    @discardableResult func responsePaginatedFilms(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<PaginatedList<Film>>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.paginatedFilmsResponseSerializer(), completionHandler: completionHandler)
    }
}
