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
        self.setupUI()
        self.setupCollectionView()
        self.setupBindings()
    }
    
    // MARK: - Reactive bindings setup
    
    fileprivate func setupBindings() {
        
        // Bind search bar text to the view model
        self.searchBar.rx
            .text
            .bindTo(self.viewModel.textSearchTrigger)
            .addDisposableTo(self.disposeBag)
        
        // Bind view model films to the table view
        self.viewModel
            .films
            .bindTo(self.collectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.addDisposableTo(self.disposeBag)
        
        // Bind table view bottom reached event to loading the next page
        self.collectionView.rx
            .reachedBottom
            .bindTo(self.viewModel.nextPageTrigger)
            .addDisposableTo(self.disposeBag)
        
        // Bind scrolling updates to dismiss keyboard when tableView is not empty
        self.collectionView.rx
            .startedDragging
            .withLatestFrom(self.viewModel.films)
            .filter { (films) -> Bool in
                return films.count > 0
            }.subscribe(onNext: { [unowned self] _ in
                self.searchBar.endEditing(true)
            }).addDisposableTo(self.disposeBag)
        
        // Bind the placeholder appearance to the data source
        self.viewModel
            .films
            .withLatestFrom(self.searchBar.rx.text) { (films, query) -> String? in
                guard films.count == 0 else { return nil }
                if query == "" { return "Search thousands of films, old or new on TMDb..."
                } else { return "No results found for '\(query)'" }
            }.subscribe(onNext: { [unowned self] (placeholderString) in
                self.placeholderLabel.text = placeholderString
                UIView.animate(withDuration: 0.2) {
                    self.placeholderView.alpha = placeholderString == nil ? 0.0 : 1.0
                    self.collectionView.alpha = placeholderString == nil ? 1.0 : 0.0
                }
            }).addDisposableTo(self.disposeBag)
        
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
        
//        self.viewModel
//            .isLoading
//            .subscribe(onNext: { (isLoading) in
//                if isLoading { self.loadingIndicator.startAnimating() }
//                else { self.loadingIndicator.stopAnimating() }
//            }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        
        self.searchBar.returnKeyType = .done
        self.searchBar.delegate = self
        // http://stackoverflow.com/questions/14272015/enable-search-button-when-searching-string-is-empty-in-default-search-bar
        if let searchTextField: UITextField = self.searchBar.subviews[0].subviews[1] as? UITextField {
            searchTextField.enablesReturnKeyAutomatically = false
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search films on TMDb", attributes: TextStyle.placeholder.attributes)
        }
        self.searchBar.addSubview(self.loadingIndicator)
        self.searchBar.keyboardAppearance = .dark

        self.placeholderLabel.apply(style: .placeholder)
        self.placeholderLabel.text = "Search thousands of films, old or new on TMDb..."
        self.placeholderView.tintColor = UIColor(commonColor: .grey)
    }
    
    fileprivate func setupCollectionView() {
        self.collectionView.registerReusableCell(FilmCollectionViewCell.self)
        self.collectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
    }
    
    fileprivate func setupScrollViewViewInset(forBottom bottom: CGFloat, animationDuration duration: Double? = nil) {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
        if let duration = duration {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: duration, animations: {
                self.collectionView.contentInset = inset
                self.collectionView.scrollIndicatorInsets = inset
                self.contentOverlayBottomMargin.constant = bottom - self.bottomLayoutGuide.length
                self.view.layoutIfNeeded()
            })
        } else {
            self.collectionView.contentInset = inset
            self.collectionView.scrollIndicatorInsets = inset
            self.contentOverlayBottomMargin.constant = bottom - self.bottomLayoutGuide.length
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Navigation handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filmDetailsViewController = segue.destination as? FilmDetailsViewController,
            let PushFilmDetailsSegue = segue as? PushFilmDetailsSegue,
            let indexPath = sender as? IndexPath,
            let cell = self.collectionView.cellForItem(at: indexPath) as? FilmCollectionViewCell {
            do {
                let film: Film = try collectionView.rx.model(indexPath)
                self.preparePushTransition(to: filmDetailsViewController, with: film, fromCell: cell, via: PushFilmDetailsSegue)
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
        self.performSegue(withIdentifier: FilmDetailsViewController.segueIdentifier, sender: indexPath)
    }
}

// MARK: -

extension SearchViewController: FilmDetailsFromCellTransitionable { }
