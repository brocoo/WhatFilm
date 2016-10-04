//
//  FilmDetailsViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 28/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FilmDetailsViewController: UIViewController {

    // MARK: - Properties
    
    private let disposeBag: DisposeBag = DisposeBag()
    var viewModel: FilmDetailsViewModel?
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var posterTempImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var filmTitleLabel: UILabel!
    
    // MARK: - UIViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        if let viewModel = self.viewModel { self.setupBindings(forViewModel: viewModel) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height: CGFloat = self.view.bounds.height - 200
        self.scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        // Set scrollView content Offset
        
    }
    
    // MARK: - Populate
    
    fileprivate func populate(forFilm film: Film) {
        if let posterPath = film.posterPath {
            self.posterTempImageView.setImage(fromTMDbPath: posterPath, withSize: .medium, animated: false)
            self.posterImageView.setImage(fromTMDbPath: posterPath, withSize: .original, animated: true)
        }
        self.filmTitleLabel.text = film.fullTitle
    }
    
    fileprivate func populate(forFilmDetail filmDetail: FilmDetail) {
        
    }
    
    // MARK: - Reactive setup
    
    fileprivate func setupBindings(forViewModel viewModel: FilmDetailsViewModel) {
        
        viewModel.film.subscribe(onNext: { [unowned self] (film) in
            self.populate(forFilm: film)
        }).addDisposableTo(self.disposeBag)
        
        viewModel.filmDetail.subscribe(onNext: { [unowned self] (filmDetail) in
            self.populate(forFilmDetail: filmDetail)
        }).addDisposableTo(self.disposeBag)
    }
}

extension FilmDetailsViewController: SegueReachable {
    
    static var segueIdentifier: String { return "FilmDetail" }
}
