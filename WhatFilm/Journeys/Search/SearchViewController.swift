//
//  HomeViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 13/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController, ReactiveDisposable {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentOverlayBottomMargin: NSLayoutConstraint!
    fileprivate var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // MARK: - Properties
    
    fileprivate let keyboardObserver: KeyboardObserver = KeyboardObserver()
    fileprivate let sizeObserver: PublishSubject<CGSize> = PublishSubject()
    fileprivate let viewModel: SearchViewModel
    fileprivate let router: Router
    fileprivate(set) var selectedCell: FilmCollectionViewCell?
    let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Lazy properties
    
    lazy private var filmsCollectionViewManager = FilmsCollectionViewManager(films: viewModel.filmsTask, sizeObserver: sizeObserver)
    
    // MARK: - Initializer
    
    init(viewModel: SearchViewModel, router: Router) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        tabBarItem = router.tabBarItem(for: .search)
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
        Analytics.track(viewContent: "Search", ofType: "View")
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
        
        searchBar
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.textSearchTrigger)
            .disposed(by: disposeBag)
        
        collectionView.rx
            .reachedBottom
            .bind(to: viewModel.nextPageTrigger)
            .disposed(by: disposeBag)
        
        collectionView.rx
            .startedDragging
            .withLatestFrom(viewModel.films)
            .filter { (films) -> Bool in
                return films.count > 0
            }.subscribe(onNext: { [unowned self] _ in
                self.searchBar.endEditing(true)
            }).disposed(by: disposeBag)
        
        collectionView.rx
            .observe(CGRect.self, "bounds")
            .flatMap { Observable.from(optional: $0?.size) }
            .distinctUntilChanged()
            .bind(to: sizeObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .films
            .asObservable()
            .withLatestFrom(searchBar.rx.text) { (films, searchQuery) -> String? in
                
                guard films.count == 0 else { return nil }
                guard let query = searchQuery, query.count > 0 else { return "Search thousands of films, old or new on TMDb..." }
                return "No results found for '\(query)'"
                
            }.subscribe(onNext: { [unowned self] (placeholderString) in
                
                self.placeholderLabel.text = placeholderString
                UIView.animate(withDuration: 0.2) {
                    self.placeholderView.alpha = placeholderString == nil ? 0.0 : 1.0
                    self.collectionView.alpha = placeholderString == nil ? 1.0 : 0.0
                }
            }).disposed(by: disposeBag)
        
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
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        
        title = "Search"
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        // http://stackoverflow.com/questions/14272015/enable-search-button-when-searching-string-is-empty-in-default-search-bar
        if let searchTextField: UITextField = searchBar.subviews[0].subviews[1] as? UITextField {
            searchTextField.enablesReturnKeyAutomatically = false
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search films on TMDb", attributes: TextStyle.placeholder.attributes)
        }
        searchBar.addSubview(loadingIndicator)
        searchBar.keyboardAppearance = .dark

        placeholderLabel.apply(style: .placeholder)
        placeholderLabel.text = "Search thousands of films, old or new on TMDb..."
        placeholderView.tintColor = UIColor(commonColor: .grey)
    }
    
    fileprivate func setupScrollViewViewInset(forBottom bottom: CGFloat, animationDuration duration: Double? = nil) {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
        if let duration = duration {
            view.layoutIfNeeded()
            UIView.animate(withDuration: duration, animations: {
                self.collectionView.contentInset = inset
                self.collectionView.scrollIndicatorInsets = inset
                self.contentOverlayBottomMargin.constant = bottom - self.bottomLayoutGuide.length
                self.view.layoutIfNeeded()
            })
        } else {
            collectionView.contentInset = inset
            collectionView.scrollIndicatorInsets = inset
            contentOverlayBottomMargin.constant = bottom - bottomLayoutGuide.length
            view.layoutIfNeeded()
        }
    }
}

// MARK: -

extension SearchViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: -

extension SearchViewController: FilmDetailsTransitionable {
    
    // MARK: - FilmDetailsTransitionable
}
