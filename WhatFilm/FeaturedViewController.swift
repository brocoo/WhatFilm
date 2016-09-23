//
//  FeaturedViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 23/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FeaturedViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate let refreshControl: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Properties
    
    private let keyboardObserver: KeyboardObserver = KeyboardObserver()
    private let viewModel: FeaturedViewModel = FeaturedViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - UICollectionViewCell layout properties
    
    fileprivate let collectionViewItemsPerRow: Int = 3
    fileprivate let collectionViewMargin: CGFloat = 15.0
    fileprivate let collectionViewItemSizeRatio: CGFloat = 2.0 / 3.0
    fileprivate var collectionViewItemWidth: CGFloat {
        return (self.collectionView.bounds.width - (CGFloat(self.collectionViewItemsPerRow + 1) * self.collectionViewMargin)) / CGFloat(self.collectionViewItemsPerRow)
    }
    fileprivate var collectionViewItemHeight: CGFloat {
        return self.collectionViewItemWidth / self.collectionViewItemSizeRatio
    }
    
    // MARK: - UIViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupCollectionView()
        self.setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.reloadTrigger.onNext(())
    }
    
    // MARK: - Reactive bindings setup
    
    fileprivate func setupBindings() {
        
        // Bind refresh control to data reload
        self.refreshControl.rx
            .controlEvent(.valueChanged)
            .filter({ self.refreshControl.isRefreshing })
            .bindTo(self.viewModel.reloadTrigger)
            .addDisposableTo(self.disposeBag)
        
        // Bind view model films to the table view
        self.viewModel
            .films
            .bindTo(self.collectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withFilm: film)
            }.addDisposableTo(self.disposeBag)
        
        // Bind view model films to the refresh control
        self.viewModel.films
            .subscribe { _ in
                self.refreshControl.endRefreshing()
            }.addDisposableTo(self.disposeBag)
        
        // Bind table view bottom reached event to loading the next page
        self.collectionView.rx
            .reachedBottom
            .bindTo(self.viewModel.nextPageTrigger)
            .addDisposableTo(self.disposeBag)
        
        // Bind keyboard updates to table view inset
        self.keyboardObserver
            .willShow
            .subscribe(onNext: { [unowned self] (keyboardInfo) in
                self.setupScrollViewViewInset(forBottom: keyboardInfo.frameEnd.height, animationDuration: keyboardInfo.animationDuration)
                }).addDisposableTo(self.disposeBag)
        
        self.keyboardObserver
            .willHide
            .subscribe(onNext: { [unowned self] (keyboardInfo) in
                self.setupScrollViewViewInset(forBottom: 0, animationDuration: keyboardInfo.animationDuration)
                }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() { }
    
    fileprivate func setupCollectionView() {
        self.collectionView.registerReusableCell(FilmCollectionViewCell.self)
        self.collectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.collectionView.addSubview(self.refreshControl)
    }
    
    fileprivate func setupScrollViewViewInset(forBottom bottom: CGFloat, animationDuration duration: Double? = nil) {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
        if let duration = duration {
            UIView.animate(withDuration: duration, animations: {
                self.collectionView.contentInset = inset
                self.collectionView.scrollIndicatorInsets = inset
            })
        } else {
            self.collectionView.contentInset = inset
            self.collectionView.scrollIndicatorInsets = inset
        }
    }
}

// MARK: -

extension FeaturedViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewItemWidth, height: self.collectionViewItemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.collectionViewMargin, left: self.collectionViewMargin, bottom: self.collectionViewMargin, right: self.collectionViewMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.collectionViewMargin
    }
}
