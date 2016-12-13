//
//  Tools.swift
//  WhatFilm
//
//  Created by Julien Ducret on 11/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa
import SDWebImage
import Alamofire

public typealias ParametersList = [String: String]

// MARK: -

public struct CollectionViewSelection {
    let collectionView: UICollectionView
    let indexPath: IndexPath
}

// MARK: - URLParametersListSerializable protocol

protocol URLParametersListSerializable {
    
    var URLParametersList: ParametersList { get }
}

// MARK: - JSONInitializable protocol

protocol JSONInitializable {
    
    init(json: JSON)
}

protocol JSONFailableInitializable {
    
    init?(json: JSON)
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


// MARK: - JSON

extension JSON {
    
    public var date: Date? {
        get {
            switch self.type {
            case .string:
                guard let dateString = self.object as? String else { return nil }
                return DateManager.SharedFormatter.date(from: dateString)
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = DateManager.SharedFormatter.string(from: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var dateValue: Date {
        get {
            guard let date = self.date else { return Date() }
            return date
        }
        set { self.date = newValue }
    }
}

// MARK: - ReusableView protocol

protocol ReusableView: class {
    
    static var DefaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    
    static var DefaultReuseIdentifier: String { return NSStringFromClass(self) }
}

// MARK: - NibLoadableView protocol

protocol NibLoadableView: class {
    
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

// MARK: - UITableView extension

extension UITableView {
    
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: ReusableView {
        self.register(T.self, forCellReuseIdentifier: T.DefaultReuseIdentifier)
    }
    
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        self.register(nib, forCellReuseIdentifier: T.DefaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.DefaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.DefaultReuseIdentifier)")
        }
        return cell
    }
}

// MARK: - UICollectionView extension

extension UICollectionView {
    
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        self.register(T.self, forCellWithReuseIdentifier: T.DefaultReuseIdentifier)
    }
    
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        self.register(nib, forCellWithReuseIdentifier: T.DefaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.DefaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.DefaultReuseIdentifier)")
        }
        return cell
    }
}

// MARK: - Reactive protocol

protocol ReactiveDisposable {
    
    var disposeBag: DisposeBag { get }
}

// MARK: - Reactive extension (UIScrollView)
// https://github.com/tryswift/RxPagination/blob/master/Pagination/UIScrollView%2BRx.swift

extension Reactive where Base: UIScrollView {
    
    public var reachedBottom: Observable<Void> {
        let scrollView = self.base as UIScrollView
        return self.contentOffset.flatMap{ [weak scrollView] (contentOffset) -> Observable<Void> in
            guard let scrollView = scrollView else { return Observable.empty() }
            let visibleHeight = scrollView.frame.height - self.base.contentInset.top - scrollView.contentInset.bottom
            let y = contentOffset.y + scrollView.contentInset.top
            let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
            return (y > threshold) ? Observable.just(()) : Observable.empty()
        }
    }
    
    public var startedDragging: Observable<Void> {
        let scrollView = self.base as UIScrollView
        return scrollView.panGestureRecognizer.rx
            .event
            .filter({ $0.state == .began })
            .map({ _ in () })
    }
}

extension Reactive where Base: UIViewController {
    
    public var viewDidLoad: Observable<Void> {
        return self.sentMessage(#selector(UIViewController.viewDidLoad)).map({ _ in return () })
    }
    
    public var viewWillAppear: Observable<Bool> {
        return self.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map({ $0.first as! Bool })
    }
    
    public var viewDidAppear: Observable<Bool> {
        return self.sentMessage(#selector(UIViewController.viewDidAppear(_:))).map({ $0.first as! Bool })
    }
    
    public var viewWillDisappear: Observable<Bool> {
        return self.sentMessage(#selector(UIViewController.viewWillDisappear(_:))).map({ $0.first as! Bool })
    }
    
    public var viewDidDisappear: Observable<Bool> {
        return self.sentMessage(#selector(UIViewController.viewDidDisappear(_:))).map({ $0.first as! Bool })
    }
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
    
    var attributes: [String: AnyObject] {
        return [NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.color]
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

