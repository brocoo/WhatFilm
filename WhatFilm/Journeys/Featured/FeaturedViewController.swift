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

final class FeaturedViewController: BaseFilmCollectionViewController, ReactiveDisposable {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var placeholderView: UIView!
    fileprivate let refreshControl: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Properties
    
    fileprivate let keyboardObserver: KeyboardObserver = KeyboardObserver()
    fileprivate let viewModel: FeaturedViewModel = FeaturedViewModel()
    let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - UIViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupCollectionView()
        self.setupBindings()
        self.viewModel.reloadTrigger.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.track(viewContent: "Featured list of film", ofType: "View")
    }
    
    // MARK: - Reactive bindings setup
    
    fileprivate func setupBindings() {
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .filter { self.refreshControl.isRefreshing }
            .bind(to: viewModel.reloadTrigger)
            .disposed(by: disposeBag)
        
        viewModel
            .filmsTask
            .filter { !$0.isLoading }
            .map { $0.result?.value ?? [] }
            .asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.disposed(by: disposeBag)
        
        viewModel
            .filmsTask
            .drive(onNext: { (task) in
                self.setupUI(for: task)
            }).disposed(by: disposeBag)
        
        collectionView.rx
            .reachedBottom
            .bind(to: self.viewModel.nextPageTrigger)
            .disposed(by: self.disposeBag)
        
        keyboardObserver
            .willShow
            .subscribe(onNext: { [unowned self] (keyboardInfo) in
                self.setupScrollViewViewInset(forBottom: keyboardInfo.frameEnd.height, animationDuration: keyboardInfo.animationDuration)
            }).disposed(by: self.disposeBag)
        keyboardObserver
            .willHide
            .subscribe(onNext: { [unowned self] (keyboardInfo) in
                self.setupScrollViewViewInset(forBottom: 0, animationDuration: keyboardInfo.animationDuration)
            }).disposed(by: self.disposeBag)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() { }
    
    fileprivate func setupCollectionView() {
        self.collectionView.registerReusableCell(FilmCollectionViewCell.self)
        self.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
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
    
    fileprivate func setupUI(`for` task: Task<[Film]>) {
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filmDetailsViewController = segue.destination as? FilmDetailsViewController,
            let PushFilmDetailsSegue = segue as? PushFilmDetailsSegue,
            let indexPath = sender as? IndexPath,
            let cell = self.collectionView.cellForItem(at: indexPath) as? FilmCollectionViewCell {
            do {
                let film: Film = try collectionView.rx.model(at: indexPath)
                self.preparePushTransition(to: filmDetailsViewController, with: film, fromCell: cell, via: PushFilmDetailsSegue)
                Analytics.track(viewContent: "Selected film", ofType: "Film", withId: "\(film.id)", withAttributes: ["Title": film.fullTitle])
            } catch { fatalError(error.localizedDescription) }
        }
    }
}

// MARK: -

extension FeaturedViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate functions
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: FilmDetailsViewController.segueIdentifier, sender: indexPath)
    }
}

extension FeaturedViewController: FilmDetailsFromCellTransitionable { }
