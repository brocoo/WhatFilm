//
//  ReusableView.swift
//  WhatFilm
//
//  Created by Julien Ducret on 2/25/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// MARK: -

protocol ReusableView: class {
    
    // MARK: -
    
    static var defaultReuseIdentifier: String { get }
}

// MARK: -

extension ReusableView where Self: UIView {
    
    // MARK: - ReusableView default implementation
    
    static var defaultReuseIdentifier: String { return NSStringFromClass(self) }
}

// MARK: -

protocol NibLoadableView: class {
    
    // MARK: -
    
    static var nibName: String { get }
}

// MARK: -

extension NibLoadableView where Self: UIView {
    
    // MARK: - NibLoadableView default implementation
    
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

// MARK: -

extension UITableView {
    
    // MARK: - UITableView extension
    
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: ReusableView {
        self.register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        self.register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
}

// MARK: -

extension UICollectionView {
    
    // MARK: - UICollectionView extension
    
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
    func registerSupplementaryView<T: UICollectionReusableView>(_: T.Type, ofKind kind: String) where T: ReusableView {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerSupplementaryView<T: UICollectionReusableView>(_: T.Type, ofKind kind: String) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, `for` indexPath: IndexPath) -> T where T: ReusableView, T: NibLoadableView {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view of kind: \(kind) with identifier: \(T.defaultReuseIdentifier)")
        }
        return view
    }
}
