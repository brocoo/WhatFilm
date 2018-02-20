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

class SearchViewController: BaseFilmCollectionViewController, ReactiveDisposable {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentOverlayBottomMargin: NSLayoutConstraint!
    fileprivate var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: - Properties
    
    fileprivate let keyboardObserver: KeyboardObserver = KeyboardObserver()
    fileprivate let viewModel: SearchViewModel = SearchViewModel()
    let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - UIViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.track(viewContent: "Search", ofType: "View")
    }
    
    // MARK: - Reactive bindings setup
    
    fileprivate func setupBindings() {
        
        searchBar
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.textSearchTrigger)
            .disposed(by: disposeBag)
        
        viewModel
            .films
            .asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.disposed(by: disposeBag)
        
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
        
//        viewModel
//            .isLoading
//            .subscribe(onNext: { (isLoading) in
//                if isLoading { loadingIndicator.startAnimating() }
//                else { loadingIndicator.stopAnimating() }
//            }).addDisposableTo(disposeBag)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        
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
    
    fileprivate func setupCollectionView() {
        collectionView.registerReusableCell(FilmCollectionViewCell.self)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
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
    
    // MARK: - Navigation handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filmDetailsViewController = segue.destination as? FilmDetailsViewController,
            let PushFilmDetailsSegue = segue as? PushFilmDetailsSegue,
            let indexPath = sender as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? FilmCollectionViewCell {
            do {
                let film: Film = try collectionView.rx.model(at: indexPath)
                preparePushTransition(to: filmDetailsViewController, with: film, fromCell: cell, via: PushFilmDetailsSegue)
                Analytics.track(viewContent: "Selected searched film", ofType: "Film", withId: "\(film.id)", withAttributes: ["Title": film.fullTitle])
            } catch { fatalError(error.localizedDescription) }
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

extension SearchViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate functions
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: FilmDetailsViewController.segueIdentifier, sender: indexPath)
    }
}

// MARK: -

extension SearchViewController: FilmDetailsFromCellTransitionable { }
