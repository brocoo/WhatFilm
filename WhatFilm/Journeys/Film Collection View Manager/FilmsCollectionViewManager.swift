//
//  FilmsCollectionViewManager.swift
//  WhatFilm
//
//  Created by Julien Ducret on 2/25/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FilmsCollectionViewManager: NSObject {
    
    // MARK: - Constants
    
    fileprivate enum UIConstants {
        static let margin: CGFloat = 15.0
        static let itemSizeRatio: CGFloat = ImageSize.posterRatio
    }
    
    // MARK: - Properties
    
    weak var collectionView: UICollectionView? {
        didSet {
            guard let collectionView = collectionView else { return }
            setup(collectionView)
        }
    }
    
    private var dataSource: PaginatedList<Film>
    private var itemSize: CGSize = .zero
    
    // MARK: - Reactive properties
    
    private let itemSelectedStream: PublishSubject<(Film, IndexPath)>
    lazy private(set) var itemSelected: Driver<(Film, IndexPath)> = {
        return itemSelectedStream.asDriver(onErrorDriveWith: Driver<(Film, IndexPath)>.from(optional: nil))
    }()
    private let disposeBag: DisposeBag
    
    // MARK: -
    
    init(films: Driver<Task<PaginatedList<Film>>>, sizeObserver: Observable<CGSize>) {
        self.dataSource = PaginatedList.empty
        self.itemSelectedStream = PublishSubject()
        self.disposeBag = DisposeBag()
        super.init()
        setupBinding(with: films, sizeObserver: sizeObserver)
    }
    
    // MARK: - Setup
    
    private func setupBinding(with films: Driver<Task<PaginatedList<Film>>>, sizeObserver: Observable<CGSize>) {
        
        films
            .map { $0.result?.value ?? PaginatedList.empty }
            .drive(onNext: { [weak self] (list) in
                self?.updateDataSource(with: list)
            }).disposed(by: disposeBag)
        
        sizeObserver
            .asDriver(onErrorJustReturn: collectionView?.bounds.size ?? .zero )
            .map { $0.asCollectionViewItemSize(margin: UIConstants.margin, sizeRatio: UIConstants.itemSizeRatio) }
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (itemSize) in
                self?.itemSize = itemSize
                self?.collectionView?.collectionViewLayout.invalidateLayout()
            }).disposed(by: disposeBag)
    }
    
    private func setup(_ collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerReusableCell(FilmCollectionViewCell.self)
        collectionView.registerSupplementaryView(LoaderCollectionReusableView.self, ofKind: UICollectionElementKindSectionFooter)
    }
    
    // MARK: -
    
    private func updateDataSource(with paginatedList: PaginatedList<Film>) {
        dataSource = paginatedList
        guard let collectionView = collectionView else { return }
        switch paginatedList.lastContentUpdate {
        case .created:
            collectionView.reloadData()
        case .newPageAdded(let pageIndex):
            let indexPaths = paginatedList.indexes(forPage: pageIndex).map { IndexPath(row: $0, section: 0) }
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }, completion: nil)
        }

    }
}

// MARK: -

extension FilmsCollectionViewManager: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilmCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let film = dataSource[indexPath.row]
        cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView: LoaderCollectionReusableView = collectionView.dequeueSupplementaryView(ofKind: kind, for: indexPath)
        return reusableView
    }
}

// MARK: -

extension FilmsCollectionViewManager: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        itemSelectedStream.onNext((dataSource[indexPath.row], indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.isHidden = !dataSource.hasMoreContent
    }
}

// MARK: -

extension FilmsCollectionViewManager: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(all: UIConstants.margin)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIConstants.margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let height: CGFloat = {
            guard dataSource.hasMoreContent else { return 0.5 }
            return LoaderCollectionReusableView.height
        }()
        return CGSize(width: collectionView.bounds.width, height: height)
    }
}

// MARK: -

extension CGSize {
    
    // MARK: - CGSize helper
    
    fileprivate func asCollectionViewItemSize(margin: CGFloat, sizeRatio: CGFloat) -> CGSize {
        let itemsPerRow: Int = {
            if width > 768 { return 4 }
            else if width > 414 { return 3 }
            else { return 2 }
        }()
        let newWidth = (width - (CGFloat(itemsPerRow + 1) * margin)) / CGFloat(itemsPerRow)
        let newHeight = newWidth / sizeRatio
        return CGSize(width: newWidth, height: newHeight)
    }
}
