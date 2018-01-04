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

public final class TMDbAPI {
    
    // MARK: - singleton
    
    static let instance: TMDbAPI = TMDbAPI()
    
    // MARK: - Properties
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    fileprivate(set) var imageManager: ImageManager? = nil
    
    // MARK: - Initializer (private)
    
    fileprivate init() {}

    // MARK: - 
    
    public func start() {
        
        // Start updating the API configuration (Every four days)
        // FIXME: - Improve this by performing background fetch
        let days: RxTimeInterval = 4.0 * 60.0 * 60.0 * 24.0
        Observable<Int>
            .timer(0, period: days, scheduler: MainScheduler.instance)
            .flatMap { (_) -> Observable<APIConfiguration> in
                return self.configuration()
            }.map { (apiConfiguration) -> ImageManager in
                return ImageManager(apiConfiguration: apiConfiguration)
            }.subscribe(onNext: { (imageManager) in
                self.imageManager = imageManager
            }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Configuration
    
    fileprivate func configuration() -> Observable<APIConfiguration> {
        return Observable.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.configuration)
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        let apiConfiguration = APIConfiguration(json: JSON(data))
                        observer.onNext(apiConfiguration)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Search films
    
    public func films(withTitle title: String, startingAtPage page: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<[Film]> {
        let parameters: FilmSearchParameters = FilmSearchParameters(query: title, atPage: page)
        return TMDbAPI.instance.films(fromList: [], with: parameters, loadNextPageTrigger: trigger)
    }
    
    fileprivate func films(fromList currentList: [Film], with parameters: FilmSearchParameters, loadNextPageTrigger trigger: Observable<Void>) -> Observable<[Film]> {
        return self.films(with: parameters).flatMap { (paginatedList) -> Observable<[Film]> in
            let newList = currentList + paginatedList.results
            if let _ = paginatedList.nextPage {
                return Observable.concat([
                    Observable.just(newList),
                    Observable.never().takeUntil(trigger),
                    self.films(fromList: newList, with: parameters.nextPage, loadNextPageTrigger: trigger)
                    ])
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
    
    public func popularFilms(startingAtPage page: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<[Film]> {
        return TMDbAPI.instance.popularFilms(fromList: [], atPage: page, loadNextPageTrigger: trigger)
    }
    
    fileprivate func popularFilms(fromList currentList: [Film], atPage page: Int, loadNextPageTrigger trigger: Observable<Void>) -> Observable<[Film]> {
        return self.popularFilms(atPage: page).flatMap { (paginatedList) -> Observable<[Film]> in
            let newList = currentList + paginatedList.results
            if let nextPage = paginatedList.nextPage {
                return Observable.concat([
                    Observable.just(newList),
                    Observable.never().takeUntil(trigger),
                    self.popularFilms(fromList: newList, atPage: nextPage, loadNextPageTrigger: trigger)
                ])
            } else { return Observable.just(newList) }
        }
    }
    
    fileprivate func popularFilms(atPage page: Int = 0) -> Observable<PaginatedList<Film>> {
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
    
    // MARK: - Film detail
    
    public func filmDetail(fromId filmId: Int) -> Observable<FilmDetail> {
        return Observable<FilmDetail>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.filmDetail(filmId: filmId))
                .validate()
                .responseFilmDetail { (response) in
                    switch response.result {
                    case .success(let filmDetail):
                        observer.onNext(filmDetail)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Film credits
    
    public func credits(forFilmId filmId: Int) -> Observable<FilmCredits> {
        return Observable<FilmCredits>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.filmCredits(filmId: filmId))
                .validate()
                .responseFilmCredits { (response) in
                    switch response.result {
                    case .success(let filmCredits):
                        observer.onNext(filmCredits)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Person
    
    public func person(forId id: Int) -> Observable<PersonDetail> {
        return Observable<PersonDetail>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.person(id: id))
                .validate()
                .responsePersonDetail { (response) in
                    switch response.result {
                    case .success(let personDetail):
                        observer.onNext(personDetail)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
    }
    
    public func filmsCredited(forPersonId id: Int) -> Observable<FilmsCredited> {
        return Observable<FilmsCredited>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.personCredits(id: id))
                .validate()
                .responseCreditedFilms { (response) in
                    switch response.result {
                    case .success(let creditedFilms):
                        observer.onNext(creditedFilms)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
    }
}

// MARK: -

extension Alamofire.DataRequest {
    
    // MARK: - Films response serializer
    
    static func filmsResponseSerializer() -> DataResponseSerializer<[Film]> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .success([]) }
                do {
                    let jsonArray = try JSON(data: data)["results"].arrayValue
                    return .success(jsonArray.map({ Film(json: $0) }))
                } catch {
                    return .failure(error)
                }
            }
        }
    }
    
    @discardableResult func responseFilms(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[Film]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.filmsResponseSerializer(), completionHandler: completionHandler)
    }
    
    // MARK: - Paginated list of films response serializer
    
    static func paginatedFilmsResponseSerializer() -> DataResponseSerializer<PaginatedList<Film>> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .success(PaginatedList.Empty()) }
                do {
                    let json = try JSON(data: data)
                    guard
                        let page = json["page"].int,
                        let totalResults = json["total_results"].int,
                        let totalPages = json["total_pages"].int else { return .success(PaginatedList.Empty()) }
                    let films = json["results"].arrayValue.map({ Film(json: $0) })
                    let paginatedList = PaginatedList(page: page - 1, totalResults: totalResults, totalPages: totalPages, results: films)
                    return .success(paginatedList)
                } catch {
                    return .failure(error)
                }
            }
        }
    }
    
    @discardableResult func responsePaginatedFilms(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<PaginatedList<Film>>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.paginatedFilmsResponseSerializer(), completionHandler: completionHandler)
    }
    
    // MARK: - Film detail response serializer
    
    static func filmDetailResponseSerializer() -> DataResponseSerializer<FilmDetail> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .failure(DataError.noData) }
                do {
                    let json = try JSON(data: data)
                    let filmDetail = FilmDetail(json: json)
                    return .success(filmDetail)
                } catch {
                    return .failure(error)
                }
            }
        }
    }
    
    @discardableResult func responseFilmDetail(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<FilmDetail>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.filmDetailResponseSerializer(), completionHandler: completionHandler)
    }
    
    // MARK: - Film credits response serializer
    
    static func filmCreditsResponseSerializer() -> DataResponseSerializer<FilmCredits> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .failure(DataError.noData) }
                do {
                    let json = try JSON(data: data)
                    let cast: [Person] = json["cast"].arrayValue.flatMap({ Person(json: $0) })
                    let crew: [Person] = json["crew"].arrayValue.flatMap({ Person(json: $0) })
                    let filmCredits = FilmCredits(cast: cast, crew: crew)
                    return .success(filmCredits)
                } catch {
                    return .failure(error)
                }
            }
        }
    }
    
    @discardableResult func responseFilmCredits(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<FilmCredits>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.filmCreditsResponseSerializer(), completionHandler: completionHandler)
    }
    
    // MARK: - Person response serializer
    
    static func personResponseSerializer() -> DataResponseSerializer<PersonDetail> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .failure(DataError.noData) }
                do {
                    let json = try JSON(data: data)
                    let person = PersonDetail(json: json)
                    return .success(person)
                } catch {
                    return .failure(error)
                }
            }
        }
    }
    
    @discardableResult func responsePersonDetail(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<PersonDetail>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.personResponseSerializer(), completionHandler: completionHandler)
    }
    
    // MARK: - Credited films for person response serializer
    
    static func creditedFilmsResponseSerializer() -> DataResponseSerializer<FilmsCredited> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .failure(DataError.noData) }
                do {
                    let json = try JSON(data: data)
                    let cast = json["cast"].arrayValue.flatMap({ FilmCredited(json: $0) })
                    let crew = json["crew"].arrayValue.flatMap({ FilmCredited(json: $0) })
                    let filmsCredited = FilmsCredited(asCast: cast, asCrew: crew)
                    return .success(filmsCredited)
                } catch {
                    return .failure(error)
                }
            }
        }
    }
    
    @discardableResult func responseCreditedFilms(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<FilmsCredited>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.creditedFilmsResponseSerializer(), completionHandler: completionHandler)
    }
}
