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
    
    // MARK: - Properties
    
    fileprivate let router: Router
    fileprivate let viewModel: FeaturedViewModel
    fileprivate(set) var selectedCell: FilmCollectionViewCell?
    
    // MARK: - Reactive properties
    
    fileprivate let keyboardObserver: KeyboardObserver = KeyboardObserver()
    fileprivate let sizeObserver: PublishSubject<CGSize> = PublishSubject()
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Lazy properties
    
    private lazy var filmsCollectionViewManager = FilmsCollectionViewManager(films: viewModel.filmsTask, sizeObserver: sizeObserver)
    fileprivate lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Initializer
    
    init(viewModel: FeaturedViewModel, router: Router) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        tabBarItem = router.tabBarItem(for: .featured)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - UIViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.track(viewContent: "Featured list of film", ofType: "View")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        sizeObserver.onNext(size)
    }
    
    // MARK: - Reactive bindings setup
    
    fileprivate func setupBindings() {
        
        filmsCollectionViewManager.collectionView = collectionView
        
        filmsCollectionViewManager
            .itemSelected
            .drive(onNext: { [unowned self] (film, cell) in
                
                self.selectedCell = cell
                self.router.showFilmDetails(for: film, from: self)
                
            }).disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .filter { self.refreshControl.isRefreshing }
            .bind(to: viewModel.reloadTrigger)
            .disposed(by: disposeBag)
        
        viewModel
            .filmsTask
            .drive(onNext: { (task) in
                self.setupUI(for: task)
            }).disposed(by: disposeBag)

        collectionView.rx
            .reachedBottom
            .bind(to: viewModel.nextPageTrigger)
            .disposed(by: disposeBag)
        
        collectionView.rx
            .observe(CGRect.self, "bounds")
            .flatMap { Observable.from(optional: $0?.size) }
            .distinctUntilChanged()
            .bind(to: sizeObserver)
            .disposed(by: disposeBag)
        
        keyboardObserver
            .willShow
            .subscribe(onNext: { [unowned self] (keyboardInfo) in
                self.setupScrollViewViewInset(forBottom: keyboardInfo.frameEnd.height, animationDuration: keyboardInfo.animationDuration)
            }).disposed(by: disposeBag)
        
        keyboardObserver
            .willHide
            .subscribe(onNext: { [unowned self] (keyboardInfo) in
                self.setupScrollViewViewInset(forBottom: 0, animationDuration: keyboardInfo.animationDuration)
            }).disposed(by: disposeBag)
        
        viewModel.reloadTrigger.onNext(())
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        title = "Featured"
        collectionView.addSubview(refreshControl)
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
    
    fileprivate func setupUI(`for` task: Task<PaginatedList<Film>>) {
        refreshControl.endRefreshing()
    }
}

// MARK: -

extension FeaturedViewController: FilmDetailsTransitionable {
    
    // MARK: - FilmDetailsTransitionable
}
