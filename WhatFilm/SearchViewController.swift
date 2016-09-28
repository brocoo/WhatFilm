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

class SearchViewController: BaseFilmCollectionViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    private let keyboardObserver: KeyboardObserver = KeyboardObserver()
    private let viewModel: SearchViewModel = SearchViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    
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
                cell.populate(withFilm: film)
            }.addDisposableTo(self.disposeBag)
        
        // Subscribe to collection view cell selection
        self.collectionView.rx
            .modelSelected(Film.self)
            .subscribe(onNext: { [weak self] (film) in
                self?.performSegue(withIdentifier: "FilmDetail", sender: film)
            }).addDisposableTo(self.disposeBag)
        
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
            .subscribe(onNext: { [unowned self] (films) in
                UIView.animate(withDuration: 0.3) {
                    self.placeholderView.alpha = films.count > 0 ? 0.0 : 1.0
                    self.collectionView.alpha = films.count > 0 ? 1.0 : 0.0
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
        
        self.viewModel.isLoading.subscribe(onNext: { (isLoading) in
            // TODO: Add loading handling
        }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        self.searchBar.placeholder = "Search films and TV shows"
    }
    
    fileprivate func setupCollectionView() {
        self.collectionView.registerReusableCell(FilmCollectionViewCell.self)
        self.collectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
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
    
    // MARK: - Navigation handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filmDetailsViewController = segue.destination as? FilmDetailsViewController, segue.identifier == FilmDetailsViewController.segueIdentifier {
            guard let film = sender as? Film else { fatalError("No film provided for the 'FilmDetailsViewController' instance") }
            let filmDetailViewModel = FilmDetailsViewModel(withFilm: film)
            filmDetailsViewController.viewModel = filmDetailViewModel
        }
    }
}
