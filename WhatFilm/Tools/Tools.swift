//
//  Tools.swift
//  WhatFilm
//
//  Created by Julien Ducret on 11/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage

// MARK: -

public struct CollectionViewSelection {
    let collectionView: UICollectionView
    let indexPath: IndexPath
}

// MARK: - URLParametersListSerializable protocol

protocol URLParametersSerializable {
    
    var asURLParameters: [URLParameter] { get }
}

// MARK: - NSUserDefault

extension UserDefaults {
    
    class func performOnce(forKey key: String, perform: () -> Void, elsePerform: (() -> Void)? = nil) {
        let once = self.standard.object(forKey: key)
        self.standard.set(true, forKey: key)
        self.standard.synchronize()
        if once == nil { perform() }
        else { elsePerform?() }
    }
}

// MARK: - Reactive protocol

protocol ReactiveDisposable {
    
    var disposeBag: DisposeBag { get }
}

// MARK: - UIImageView extension 

extension UIImageView {
    
    func setImage(fromTMDbPath path: ImagePath, withSize size: ImageSize, animatedOnce: Bool = true, withPlaceholder placeholder: UIImage? = nil) {
        guard let imageURL = TMDbAPI.instance.imageManager?.url(fromTMDbPath: path, withSize: size) else { return }
        let hasImage: Bool = (self.image != nil)
        self.sd_setImage(with: imageURL, placeholderImage: nil, options: .avoidAutoSetImage) { [weak self] (image, error, cacheType, url) in
            if animatedOnce && !hasImage && cacheType == .none {
                self?.alpha = 0.0
                UIView.animate(withDuration: 0.5) { self?.alpha = 1.0 }
            }
            self?.image = image
        }
    }
}

// MARK: - SegueReachable protocol

protocol SegueReachable: class {
    
    static var segueIdentifier: String { get }
}

// MARK: - TextStyle extension

extension TextStyle {
    
    var attributes: [NSAttributedStringKey: AnyObject] {
        return [NSAttributedStringKey.font: self.font, NSAttributedStringKey.foregroundColor: self.color]
    }
}

// MARK: - UILabel extension

extension UILabel {
    
    func apply(style: TextStyle) {
        self.font = style.font
        self.textColor = style.color
    }
}

// MARK: - Custom errors

public enum DataError: Error {
    
    case noData
}

// MARK: - Key window

extension UIApplication {
    
    static var window: UIWindow? {
        guard let delegate = self.shared.delegate else { return nil }
        return delegate.window ?? nil
    }
}

func unique<S: Sequence, E: Hashable>(source: S) -> [E] where E==S.Iterator.Element {
    var seen: [E:Bool] = [:]
    return source.filter { seen.updateValue(true, forKey: $0) == nil }
}

// MARK: - UIEdgeInsets

extension UIEdgeInsets {
    
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}
