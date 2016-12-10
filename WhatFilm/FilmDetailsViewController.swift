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
import SDWebImage

// MARK: -

public final class FilmDetailsViewController: UIViewController, ReactiveDisposable {

    // MARK: - Properties
    
    let disposeBag: DisposeBag = DisposeBag()
    var viewModel: FilmDetailsViewModel?
    var backgroundImagePath: Observable<ImagePath?> = Observable.empty()
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var fakeNavigationBar: UIView!
    @IBOutlet weak var fakeNavigationBarHeight: NSLayoutConstraint!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var filmOverviewLabel: UILabel!
    @IBOutlet weak var filmSubDetailsView: UIView!
    @IBOutlet weak var filmRuntimeImageView: UIImageView!
    @IBOutlet weak var filmRuntimeLabel: UILabel!
    @IBOutlet weak var filmRatingImageView: UIImageView!
    @IBOutlet weak var filmRatingLabel: UILabel!
    @IBOutlet weak var creditsView: UIView!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var crewCollectionView: UICollectionView!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var videosLabel: UILabel!
    @IBOutlet weak var videosCollectionView: UICollectionView!
    
    // MARK: - UIViewController life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupCollectionViews()
        if let viewModel = self.viewModel { self.setupBindings(forViewModel: viewModel) }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.fakeNavigationBarHeight.constant = self.topLayoutGuide.length
        
        // Adjust scrollview insets based on film title
        let height: CGFloat = self.view.bounds.width / ImageSize.backdropRatio
        self.scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        self.fakeNavigationBar.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        self.filmTitleLabel.apply(style: .filmDetailTitle)
        self.filmSubDetailsView.alpha = 0.0
        self.filmSubDetailsView.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        self.filmRuntimeImageView.image = #imageLiteral(resourceName: "Time_Icon").withRenderingMode(.alwaysTemplate)
        self.filmRuntimeImageView.tintColor = UIColor(commonColor: .yellow)
        self.filmRuntimeLabel.apply(style: .filmRating)
        self.filmRatingImageView.image = #imageLiteral(resourceName: "Rating_Icon").withRenderingMode(.alwaysTemplate)
        self.filmRatingImageView.tintColor = UIColor(commonColor: .yellow)
        self.filmRatingLabel.apply(style: .filmRating)
        self.filmOverviewLabel.apply(style: .body)
        self.creditsView.alpha = 0.0
        self.crewLabel.apply(style: .filmDetailTitle)
        self.castLabel.apply(style: .filmDetailTitle)
        self.videosLabel.apply(style: .filmDetailTitle)
    }
    
    fileprivate func setupCollectionViews() {
        self.crewCollectionView.registerReusableCell(PersonCollectionViewCell.self)
        self.crewCollectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.crewCollectionView.showsHorizontalScrollIndicator = false
        self.castCollectionView.registerReusableCell(PersonCollectionViewCell.self)
        self.castCollectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.castCollectionView.showsHorizontalScrollIndicator = false
        self.videosCollectionView.registerReusableCell(VideoCollectionViewCell.self)
        self.videosCollectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.videosCollectionView.showsHorizontalScrollIndicator = false
    }
    
    fileprivate func updateBackdropImageViewHeight(forScrollOffset offset: CGPoint?) {
        if let height = offset?.y {
            self.backdropImageViewHeight.constant = max(0.0, -height)
        } else {
            let height: CGFloat = self.view.bounds.width / ImageSize.backdropRatio
            self.backdropImageViewHeight.constant = max(0.0, height)
        }
    }
    
    // MARK: - Populate
    
    fileprivate func populate(forFilmDetail filmDetail: FilmDetail) {
        UIView.animate(withDuration: 0.2) { self.filmSubDetailsView.alpha = 1.0 }
        if let runtime = filmDetail.runtime { self.filmRuntimeLabel.text = "\(runtime) min" }
        else { self.filmRuntimeLabel.text = " - " }
        self.filmRatingLabel.text = "\(filmDetail.voteAverage)/10"
        self.blurredImageView.contentMode = .scaleAspectFill
        if let backdropPath = filmDetail.backdropPath {
            if let posterPath = filmDetail.posterPath { self.blurredImageView.setImage(fromTMDbPath: posterPath, withSize: .medium) }
            self.backdropImageView.contentMode = .scaleAspectFill
            self.backdropImageView.setImage(fromTMDbPath: backdropPath, withSize: .medium, animated: true)
            self.backdropImageView.backgroundColor = UIColor.clear
        } else if let posterPath = filmDetail.posterPath {
            self.blurredImageView.setImage(fromTMDbPath: posterPath, withSize: .medium)
            self.backdropImageView.contentMode = .scaleAspectFit
            self.backdropImageView.setImage(fromTMDbPath: posterPath, withSize: .medium)
            self.backdropImageView.backgroundColor = UIColor.clear
        } else {
            self.blurredImageView.image = nil
            self.backdropImageView.contentMode = .scaleAspectFit
            self.backdropImageView.image = #imageLiteral(resourceName: "Logo_Icon")
            self.backdropImageView.backgroundColor = UIColor.groupTableViewBackground
        }
        self.filmTitleLabel.text = filmDetail.fullTitle.uppercased()
        self.filmOverviewLabel.text = filmDetail.overview
    }
    
    public func prePopulate(forFilm film: Film) {
        if let posterPath = film.posterPath { self.blurredImageView.setImage(fromTMDbPath: posterPath, withSize: .medium, animated: true) }
        self.filmTitleLabel.text = film.fullTitle.uppercased()
        self.filmOverviewLabel.text = film.overview
    }
    
    // MARK: - Reactive setup
    
    fileprivate func setupBindings(forViewModel viewModel: FilmDetailsViewModel) {
        
        viewModel
            .filmDetail
            .subscribe(onNext: { [weak self] (filmDetail) in
                self?.populate(forFilmDetail: filmDetail)
            }).addDisposableTo(self.disposeBag)
        
        self.backgroundImagePath = viewModel.filmDetail.map { (filmDetail) -> ImagePath? in
            return filmDetail.posterPath ?? filmDetail.backdropPath
        }
        
        viewModel
            .credits
            .subscribe(onNext: { [weak self] (credits) in
                UIView.animate(withDuration: 0.2) { self?.creditsView.alpha = 1.0 }
            }).addDisposableTo(self.disposeBag)
        
        self.scrollView.rx.contentOffset.subscribe { [weak self] (contentOffset) in
            self?.updateBackdropImageViewHeight(forScrollOffset: contentOffset.element)
        }.addDisposableTo(self.disposeBag)
        
        viewModel
            .credits
            .map({ $0.crew })
            .bindTo(self.crewCollectionView.rx.items(cellIdentifier: PersonCollectionViewCell.DefaultReuseIdentifier, cellType: PersonCollectionViewCell.self)) {
                (row, person, cell) in
                cell.populate(with: person)
            }.addDisposableTo(self.disposeBag)
        
        viewModel
            .credits
            .map({ $0.cast })
            .bindTo(self.castCollectionView.rx.items(cellIdentifier: PersonCollectionViewCell.DefaultReuseIdentifier, cellType: PersonCollectionViewCell.self)) {
                (row, person, cell) in
                cell.populate(with: person)
            }.addDisposableTo(self.disposeBag)
        
        viewModel
            .filmDetail
            .map({ $0.videos })
            .bindTo(self.videosCollectionView.rx.items(cellIdentifier: VideoCollectionViewCell.DefaultReuseIdentifier, cellType: VideoCollectionViewCell.self)) {
                (row, video, cell) in
                if let thumbnailURL = video.youtubeThumbnailURL {
                    cell.videoThumbnailImageView.sd_setImage(with: thumbnailURL)
                } else {
                    cell.videoThumbnailImageView.image = nil
                }
            }.addDisposableTo(self.disposeBag)
        
        self.videosCollectionView.rx.modelSelected(Video.self).subscribe { [weak self] (event) in
            guard let video = event.element else { return }
            self?.play(video: video)
        }.addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Actions handling
    
    fileprivate func play(video: Video) {
        guard let url = video.youtubeURL else { return }
        UIApplication.shared.openURL(url)
    }
    
    // MARK: - Navigation handling
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let personViewController = segue.destination as? PersonViewController,
            let sender = sender as? CollectionViewSelection {
            do {
                let person: Person = try sender.collectionView.rx.model(sender.indexPath)
                let personViewModel = PersonViewModel(withPersonId: person.id)
                personViewController.viewModel = personViewModel
                personViewController.backgroundImagePath = self.backgroundImagePath
                personViewController.rx.viewDidLoad.subscribe(onNext: { _ in
                    personViewController.prePopulate(forPerson: person)
                }).addDisposableTo(self.disposeBag)
            } catch { fatalError(error.localizedDescription) }
        }
        
        // TODO: - Implement custom segue to person
        
//        if let personViewController = segue.destination as? PersonViewController,
//            let pushPersonSegue = segue as? PushPersonSegue,
//            let sender = sender as? CollectionViewSelection,
//            let cell = sender.collectionView.cellForItem(at: sender.indexPath) as? PersonCollectionViewCell {
//            do {
//                let person: Person = try sender.collectionView.rx.model(sender.indexPath)
//                personViewController.backgroundImagePath = self.backgroundImagePath
//                self.preparePushTransition(to: personViewController, with: person, fromCell: cell, andBackgroundImagePath: self.backgroundImagePath, via: pushPersonSegue)
//            } catch { fatalError(error.localizedDescription) }
//        }
    }
}

// MARK: -

extension FilmDetailsViewController: SegueReachable {
    
    // MARK: - SegueReachable
    
    static var segueIdentifier: String { return PushFilmDetailsSegue.identifier }
}

// MARK: - 

extension FilmDetailsViewController: UICollectionViewDelegate {
    
    // MARK: - UITableViewDelegate functions
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sender = CollectionViewSelection(collectionView: collectionView, indexPath: indexPath)
        self.performSegue(withIdentifier: PersonViewController.segueIdentifier, sender: sender)
    }
}

// MARK: -

extension FilmDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout functions
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.videosCollectionView {
            let width: CGFloat = collectionView.bounds.height * VideoCollectionViewCell.imageRatio
            return CGSize(width: width, height: collectionView.bounds.height)
        } else {
            return CGSize(width: 80.0, height: collectionView.bounds.height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
}

extension FilmDetailsViewController: PersonFromCellTransitionable { }
