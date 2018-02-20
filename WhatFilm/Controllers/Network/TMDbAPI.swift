//
//  TMDbAPI.swift
//  WhatFilm
//
//  Created by Julien Ducret on 15/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift

public final class TMDbAPI {
    
    // MARK: - singleton
    
    static let instance: TMDbAPI = TMDbAPI()
    
    // MARK: - Properties
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    fileprivate(set) var imageManager: ImageManager? = nil
    
    lazy private var service: Service = setupService()
    
    lazy private var apiKey: String = {
        guard let filePath: String = Bundle.main.path(forResource: "Services", ofType: "plist") else { fatalError("Couldn't find Services.plist") }
        guard let dict = NSDictionary(contentsOfFile: filePath) else { fatalError("Can't read Services.plist") }
        guard let apiKey = dict["TMDbAPIKey"] as? String else { fatalError("Couldn't find a value for 'TMDbAPIKey'") }
        return apiKey
    }()
    
    // MARK: - Initializer (private)
    
    fileprivate init() {}
    
    // MARK: - Service
    
    private func setupService() -> Service {
        let urlSession = URLSession.shared
        let defaultParameters = [URLParameter(key: "api_key", value: apiKey)]
        let configuration = ServiceConfiguration(urlScheme: "https", urlHost: "api.themoviedb.org", defaultHTTPHeaders: [:], defaultURLParameters: defaultParameters)
        return Service(session: urlSession, configuration: configuration)
    }

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
            }).disposed(by: self.disposeBag)
    }
    
    
    // MARK: - Helper functions]
    
    private func executeAsObservable<T: Decodable>(_ request: RequestProtocol) -> Observable<T> {
        return Observable.create { (observer) -> Disposable in
            let completion: (DecodableResponse<T>) -> Void = { response in
                switch response.decodedData {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            do {
                try self.service.perform(request: request, onCompletion: completion)
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }
    
    // MARK: - Configuration
    
    fileprivate func configuration() -> Observable<APIConfiguration> {
        return executeAsObservable(Endpoint.configuration)
    }
    
    // MARK: - Search films
    
    public func films(withTitle title: String, startingAtPage page: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<[Film]> {
        let parameters: FilmSearchParameters = FilmSearchParameters(query: title, page: page)
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
        return executeAsObservable(Endpoint.searchFilms(parameters: parameters))
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
        return executeAsObservable(Endpoint.popularFilms(page: page))
    }
    
    // MARK: - Film detail
    
    public func filmDetail(fromId filmId: Int) -> Observable<FilmDetail> {
        return executeAsObservable(Endpoint.filmDetail(filmId: filmId))
    }
    
    // MARK: - Film credits
    
    public func credits(forFilmId filmId: Int) -> Observable<FilmCredits> {
        return executeAsObservable(Endpoint.filmCredits(filmId: filmId))
    }
    
    // MARK: - Person
    
    public func person(forId id: Int) -> Observable<PersonDetail> {
        return executeAsObservable(Endpoint.person(id: id))
    }
    
    public func filmsCredited(forPersonId id: Int) -> Observable<PersonCreditedFilms> {
        return executeAsObservable(Endpoint.personCredits(id: id))
    }
}
