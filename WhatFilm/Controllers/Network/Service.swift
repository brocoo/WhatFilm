//
//  RequestPerformer.swift
//  WhatFilm
//
//  Created by Julien Ducret on 1/14/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation
import RxSwift

// MARK: -

final class Service {
    
    // MARK: - Properties
    
    let session: URLSession
    let configuration: ServiceConfiguration
    
    // MARK: - Initializer
    
    init(session: URLSession, configuration: ServiceConfiguration) {
        self.session = session
        self.configuration = configuration
    }
    
    // MARK: - Request perfoming method
    
    func perform<T: ResponseProtocol>(request: RequestProtocol, onCompletion: @escaping (T) -> Void) throws {
        let urlRequest = try makeURLRequest(for: request)
        let task = session.dataTask(with: urlRequest) { [weak self] (data, urlResponse, error) in
            guard let `self` = self else { return }
            let response: T = self.makeResponse(from: request, data: data, urlResponse: urlResponse, error: error)
            print(response)
            onCompletion(response)
        }
        task.resume()
    }
    
    // MARK: - Private helper methods
    
    private func makeResponse<T: ResponseProtocol>(from request: RequestProtocol, data: Data?, urlResponse: URLResponse?, error: Error?) -> T {
        let dataResult: Result<Data> = {
            if let data = data {
                return Result(data)
            } else {
                let serviceError = error ?? ServiceError.unknown(urlResponse: urlResponse)
                return Result(serviceError)
            }
        }()
        return T(request: request, data: dataResult)
    }
    
    private func makeURLRequest(`for` request: RequestProtocol) throws -> URLRequest {
        let components = makeComponents(for: request)
        guard let url = components.url else { throw ServiceError.urlFailedBuilding(components: components) }
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.allHTTPHeaderFields = configuration.defaultHTTPHeaders.merging(request.headers, uniquingKeysWith: { $1 })
        return urlRequest
    }
    
    private func makeComponents(`for` request: RequestProtocol) -> URLComponents {
        var components = URLComponents()
        components.host = configuration.urlHost
        components.scheme = configuration.urlScheme
        components.path = request.path
        components.queryItems = (configuration.defaultURLParameters + request.parameters).map { URLQueryItem(name: $0.key, value: $0.value) }
        return components
    }
}

// MARK: - Service error

public enum ServiceError: Error {
    
    case unknown(urlResponse: URLResponse?)
    case urlFailedBuilding(components: URLComponents)
}

// MARK: - Extension

extension Error {
    
    var isServiceRelated: Bool { return (self as? ServiceError) != nil }
}
