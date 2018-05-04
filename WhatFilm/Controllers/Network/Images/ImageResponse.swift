//
//  ImageResponse.swift
//  WhatFilm
//
//  Created by Julien Ducret on 4/26/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation
import UIKit

enum ImageResponseError: Error {
    case invalidImageData(Data)
}

// MARK: -

class ImageResponse: ResponseProtocol {
    
    // MARK: - Properties
    
    let request: RequestProtocol
    let data: Result<Data>
    
    // MARK: - Lazy properties
    
    private(set) lazy var image: Result<UIImage> = {
        return data.flatMap { (data) -> Result<UIImage> in
            guard let image = UIImage(data: data) else { return Result.failure(ImageResponseError.invalidImageData(data)) }
            return Result(image)
        }
    }()
    
    // MARK: - Initializer
    
    required init(request: RequestProtocol, data: Result<Data>) {
        self.request = request
        self.data = data
    }
}
