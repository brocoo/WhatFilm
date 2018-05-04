//
//  CacheProtocol.swift
//  WhatFilm
//
//  Created by Julien Ducret on 4/26/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation

// MARK: -

protocol RessourceCacheProtocol {
    
    associatedtype Key
    associatedtype Ressource
    
    func cachedRessource(`for` key: Key) -> Ressource?
    func cache(_ ressource: Ressource, `for` key: Key)
}
