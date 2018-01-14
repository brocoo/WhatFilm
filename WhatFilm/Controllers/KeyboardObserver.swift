//
//  KeyboardObserver.swift
//  WhatFilm
//
//  Created by Julien Ducret on 16/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

// Credit to muukii ()
// https://gist.github.com/muukii/a914b5bc2175f389a4348316fdf8acc9#file-keyboardobserver-swift

import Foundation
import RxSwift
import RxCocoa

// MARK:

public struct KeyboardInfo {
    
    // MARK: - Properties
    
    public let frameBegin: CGRect
    public let frameEnd: CGRect
    public let animationDuration: Double
    
    // MARK: - Initializer
    
    init(notification: Notification) {
        self.frameEnd = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        self.frameBegin = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        self.animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
    }
}

// MARK:

public final class KeyboardObserver {
    
    // MARK: - Properties
    
    public let willChangeFrame = PublishSubject<KeyboardInfo>()
    public let didChangeFrame = PublishSubject<KeyboardInfo>()
    public let willShow = PublishSubject<KeyboardInfo>()
    public let didShow = PublishSubject<KeyboardInfo>()
    public let willHide = PublishSubject<KeyboardInfo>()
    public let didHide = PublishSubject<KeyboardInfo>()
    
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    public init() {
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillChangeFrame)
            .map { KeyboardInfo(notification: $0) }
            .bind(to: self.willChangeFrame)
            .disposed(by: self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardDidChangeFrame)
            .map { KeyboardInfo(notification: $0) }
            .bind(to: self.didChangeFrame)
            .disposed(by: self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .map { KeyboardInfo(notification: $0) }
            .bind(to: self.willShow)
            .disposed(by: self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardDidShow)
            .map { KeyboardInfo(notification: $0) }
            .bind(to: self.didShow)
            .disposed(by: self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .map { KeyboardInfo(notification: $0) }
            .bind(to: self.willHide)
            .disposed(by: self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardDidHide)
            .map { KeyboardInfo(notification: $0) }
            .bind(to: self.didHide)
            .disposed(by: self.disposeBag)
    }
}
