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
    
    // MARK: - Properties
    
    fileprivate let apiConfiguration: BehaviorSubject<APIConfiguration?>
    fileprivate let disposeBag: DisposeBag
    private var service: Service?
    
    // MARK: - Lazy properties
    
    lazy private var apiKey: String = {
        guard let filePath: String = Bundle.main.path(forResource: "Services", ofType: "plist") else { fatalError("Couldn't find Services.plist") }
        guard let dict = NSDictionary(contentsOfFile: filePath) else { fatalError("Can't read Services.plist") }
        guard let apiKey = dict["TMDbAPIKey"] as? String else { fatalError("Couldn't find a value for 'TMDbAPIKey'") }
        return apiKey
    }()
    
    lazy fileprivate var imageCache: ImageCache? = {
        return try? ImageCache()
    }()
    
    fileprivate let imageManager: ReplaySubject<ImageManager> = ReplaySubject.create(bufferSize: 1)
    
    // MARK: - Initializer
    
    init() {
        apiConfiguration = BehaviorSubject(value: nil)
        disposeBag = DisposeBag()
    }
    
    // MARK: - Service
    
    private func setupService(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Service {
        
        let urlSession: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            return URLSession(configuration: configuration)
        }()
        
        let serviceConfiguration: ServiceConfiguration = {
            let defaultParameters = [URLParameter(key: "api_key", value: apiKey)]
            return ServiceConfiguration(defaultUrlScheme: "https", defaultUrlHost: "api.themoviedb.org", defaultHTTPHeaders: [:], defaultURLParameters: defaultParameters)
        }()
        
        return Service(session: urlSession, configuration: serviceConfiguration)
    }

    // MARK: - 
    
    public func start(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        service = setupService(with: launchOptions)
        
        // Start updating the API configuration (Every four days)
        // FIXME: - Improve this by performing background fetch
        let days: RxTimeInterval = 4.0 * 60.0 * 60.0 * 24.0
        Observable<Int>
            .timer(0, period: days, scheduler: MainScheduler.instance)
            .flatMap { [weak self] (_) -> Observable<APIConfiguration> in
                guard let `self` = self else { return Observable.empty() }
                return self.decodedResponseAsObservable(for: Endpoint.configuration)
            }.map { (apiConfiguration) -> ImageManager in
                return ImageManager(apiConfiguration: apiConfiguration)
            }.bind(to: imageManager)
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Helper functions
    
    private func decodedResponseAsObservable<T: Decodable>(`for` request: RequestProtocol) -> Observable<T> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
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
                guard let service = self.service else { throw ServiceError.serviceNotInitialized }
                try service.perform(request: request, onCompletion: completion)
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }
    
    // MARK: - Configuration
    
    fileprivate func configuration() -> Observable<APIConfiguration> {
        return decodedResponseAsObservable(for: Endpoint.configuration)
    }
    
    // MARK: - Search films
    
    public func films(withTitle title: String, startingAtPage pageIndex: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<PaginatedList<Film>> {
        let parameters: FilmSearchParameters = FilmSearchParameters(query: title, page: pageIndex)
        return films(currentPaginatedList: nil, with: parameters, loadNextPageTrigger: trigger)
    }
    
    fileprivate func films(currentPaginatedList currentList: PaginatedList<Film>?, with parameters: FilmSearchParameters, loadNextPageTrigger trigger: Observable<Void>) -> Observable<PaginatedList<Film>> {
        let films: Observable<Page<Film>> = decodedResponseAsObservable(for: Endpoint.searchFilms(parameters: parameters))
        return films.flatMapLatest { [weak self, weak trigger] (page) -> Observable<PaginatedList<Film>> in
            do {
                
                let newList = try { () throws -> (PaginatedList<Film>) in
                    guard let list = currentList else { return try PaginatedList(with: page) }
                    return try list.appending(page)
                }()
                
                guard page.hasNextPage, let `self` = self, let trigger = trigger else { return Observable.just(newList) }
                
                return Observable.concat([
                    Observable.just(newList),
                    Observable.never().takeUntil(trigger),
                    self.films(currentPaginatedList: newList,
                               with: parameters.forPage(page.nextPageIndex),
                               loadNextPageTrigger: trigger)
                    ])

            } catch { return Observable.error(error) }
        }
    }
    
    // MARK: - Popular films
    
    public func popularFilms(startingAtPage pageIndex: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<PaginatedList<Film>> {
        return popularFilms(currentPaginatedList: nil, atPage: pageIndex, loadNextPageTrigger: trigger)
    }
    
    fileprivate func popularFilms(currentPaginatedList currentList: PaginatedList<Film>?, atPage pageIndex: Int, loadNextPageTrigger trigger: Observable<Void>) -> Observable<PaginatedList<Film>> {
        let popularFilms: Observable<Page<Film>> = decodedResponseAsObservable(for: Endpoint.popularFilms(page: pageIndex))
        return popularFilms.flatMapLatest { [weak self, weak trigger] (page) -> Observable<PaginatedList<Film>> in
            do {
                
                let newList = try { () throws -> (PaginatedList<Film>) in
                    guard let list = currentList else { return try PaginatedList(with: page) }
                    return try list.appending(page)
                }()
                
                guard page.hasNextPage, let `self` = self, let trigger = trigger else { return Observable.just(newList) }
                
                return Observable.concat([
                    Observable.just(newList),
                    Observable.never().takeUntil(trigger),
                    self.popularFilms(currentPaginatedList: newList,
                                      atPage: page.nextPageIndex,
                                      loadNextPageTrigger: trigger)
                    ])
                
            } catch { return Observable.error(error) }
        }
    }
    
    // MARK: - Film detail
    
    public func filmDetail(fromId filmId: Int) -> Observable<FilmDetail> {
        return decodedResponseAsObservable(for: Endpoint.filmDetail(filmId: filmId))
    }
    
    // MARK: - Film credits
    
    public func credits(forFilmId filmId: Int) -> Observable<FilmCredits> {
        return decodedResponseAsObservable(for: Endpoint.filmCredits(filmId: filmId))
    }
    
    // MARK: - Person
    
    public func person(forId id: Int) -> Observable<PersonDetail> {
        return decodedResponseAsObservable(for: Endpoint.person(id: id))
    }
    
    public func filmsCredited(forPersonId id: Int) -> Observable<PersonCreditedFilms> {
        return decodedResponseAsObservable(for: Endpoint.personCredits(id: id))
    }
}

// MARK: -

extension TMDbAPI: ImageAPIProtocol {
    
    // MARK: - ImageAPI
    
    private func imageResponseAsObservable(`for` request: RequestProtocol) -> Observable<CachedImage> {
        if let image = imageCache?.cachedRessource(for: request.path) {
            return Observable.just(CachedImage(image: image, cached: true))
        } else {
            return Observable.create { [weak self] (observer) -> Disposable in
                let completion: (ImageResponse) -> Void = { response in
                    switch response.image {
                    case .success(let image):
                        self?.imageCache?.cache(image, for: request.path)
                        observer.onNext(CachedImage(image: image, cached: false))
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
                do {
                    guard let `self` = self, let service = self.service else { throw ServiceError.serviceNotInitialized }
                    try service.perform(request: request, onCompletion: completion)
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
    
    func image(withSize size: ImageSize, atPath path: ImagePath) -> Observable<CachedImage> {
        
        let sizePathTuple: (size: ImageSize, path: ImagePath) = (size: size, path: path)
        return Observable
            .just(sizePathTuple)
            .withLatestFrom(imageManager) { (tuple, imageManager) -> ((size: ImageSize, path: ImagePath), ImageManager) in
                return (tuple, imageManager)
            }.flatMapLatest() { [weak self] (tuple, imageManager) -> Observable<CachedImage> in
                guard let `self` = self else { return Observable.empty() }
                do {
                    let request = try imageManager.imageRequest(fromPath: tuple.path, withSize: tuple.size)
                    return self.imageResponseAsObservable(for: request)
                } catch { return Observable.error(error) }
        }
    }
}
