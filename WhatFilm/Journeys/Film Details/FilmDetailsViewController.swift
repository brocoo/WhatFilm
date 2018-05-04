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

final class FilmDetailsViewController: UIViewController, ReactiveDisposable {
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var blurredImageView: UIImageView!
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
    @IBOutlet weak var castView: UIView!
    @IBOutlet weak var castViewHeight: NSLayoutConstraint!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var crewView: UIView!
    @IBOutlet weak var crewViewHeight: NSLayoutConstraint!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var crewCollectionView: UICollectionView!
    @IBOutlet weak var videosView: UIView!
    @IBOutlet weak var videosViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videosLabel: UILabel!
    @IBOutlet weak var videosCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    fileprivate let router: Router
    fileprivate let viewModel: FilmDetailsViewModel
    
    // MARK: - Reactive properties
    
    private lazy var backgroundImagePath: Driver<ImagePath> = makeBackgroundImagePath()
    let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(viewModel: FilmDetailsViewModel, router: Router) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - UIViewController life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViews()
        setupBindings()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.track(viewContent: "Film Details", ofType: "View")
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height: CGFloat = self.view.bounds.width / ImageSize.backdropRatio
        self.scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        self.filmTitleLabel.apply(style: .filmDetailTitle)
        self.filmTitleLabel.text = viewModel.film.fullTitle.uppercased()
        self.filmSubDetailsView.alpha = 0.0
        self.filmSubDetailsView.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        self.filmRuntimeImageView.image = #imageLiteral(resourceName: "Time_Icon").withRenderingMode(.alwaysTemplate)
        self.filmRuntimeImageView.tintColor = UIColor(commonColor: .yellow)
        self.filmRuntimeLabel.apply(style: .filmRating)
        self.filmRatingImageView.image = #imageLiteral(resourceName: "Rating_Icon").withRenderingMode(.alwaysTemplate)
        self.filmRatingImageView.tintColor = UIColor(commonColor: .yellow)
        self.filmRatingLabel.apply(style: .filmRating)
        self.filmOverviewLabel.apply(style: .body)
        self.filmOverviewLabel.text = viewModel.film.overview
        self.creditsView.alpha = 0.0
        self.crewLabel.apply(style: .filmDetailTitle)
        self.castLabel.apply(style: .filmDetailTitle)
        self.videosLabel.apply(style: .filmDetailTitle)
        if let posterPath = viewModel.film.posterPath {
            self.blurredImageView.setImage(fromPath: posterPath, withSize: .medium)
        }
    }
    
    fileprivate func setupCollectionViews() {
        self.crewCollectionView.registerReusableCell(PersonCollectionViewCell.self)
        self.crewCollectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.crewCollectionView.showsHorizontalScrollIndicator = false
        self.castCollectionView.registerReusableCell(PersonCollectionViewCell.self)
        self.castCollectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.castCollectionView.showsHorizontalScrollIndicator = false
        self.videosCollectionView.registerReusableCell(VideoCollectionViewCell.self)
        self.videosCollectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
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
    
    fileprivate func makeBackgroundImagePath() -> Driver<ImagePath> {
        
        return viewModel
            .filmDetail
            .flatMap { (result) -> Driver<ImagePath> in
                let value: ImagePath? = {
                    guard let filmDetail = result.value else { return nil }
                    return filmDetail.posterPath ?? filmDetail.backdropPath
                }()
                return Driver.from(optional: value)
        }
    }
    
    fileprivate func populate(forFilmDetail filmDetail: FilmDetail) {
        UIView.animate(withDuration: 0.2) { self.filmSubDetailsView.alpha = 1.0 }
        if let runtime = filmDetail.runtime { self.filmRuntimeLabel.text = "\(runtime) min" }
        else { self.filmRuntimeLabel.text = " - " }
        self.filmRatingLabel.text = "\(filmDetail.voteAverage)/10"
        self.blurredImageView.contentMode = .scaleAspectFill
        if let backdropPath = filmDetail.backdropPath {
            if let posterPath = filmDetail.posterPath { self.blurredImageView.setImage(fromPath: posterPath, withSize: .medium) }
            self.backdropImageView.contentMode = .scaleAspectFill
            self.backdropImageView.setImage(fromPath: backdropPath, withSize: .medium)
            self.backdropImageView.backgroundColor = UIColor.clear
        } else if let posterPath = filmDetail.posterPath {
            self.blurredImageView.setImage(fromPath: posterPath, withSize: .medium)
            self.backdropImageView.contentMode = .scaleAspectFill
            self.backdropImageView.setImage(fromPath: posterPath, withSize: .medium)
            self.backdropImageView.backgroundColor = UIColor.clear
        } else {
            self.blurredImageView.image = nil
            self.backdropImageView.contentMode = .scaleAspectFit
            self.backdropImageView.image = #imageLiteral(resourceName: "Logo_Icon")
            self.backdropImageView.backgroundColor = UIColor.groupTableViewBackground
        }
        self.filmTitleLabel.text = filmDetail.fullTitle.uppercased()
        self.filmOverviewLabel.text = filmDetail.overview
        self.videosView.alpha = 0.0
    }
    
    // MARK: - Reactive setup
    
    fileprivate func setupBindings() {
        
        viewModel
            .filmDetail
            .drive(onNext: { [weak self] (result) in
                switch result {
                case .success(let value): self?.populate(forFilmDetail: value)
                case .failure: break
                }
            }).disposed(by: disposeBag)
        
        scrollView.rx
            .contentOffset
            .subscribe { [weak self] (contentOffset) in
                self?.updateBackdropImageViewHeight(forScrollOffset: contentOffset.element)
            }.disposed(by: disposeBag)
        
        viewModel
            .credits
            .map { $0.value?.crew ?? [] }
            .asObservable()
            .bind(to: self.crewCollectionView.rx.items(cellIdentifier: PersonCollectionViewCell.defaultReuseIdentifier, cellType: PersonCollectionViewCell.self)) {
                (row, person, cell) in
                cell.populate(with: person)
            }.disposed(by: disposeBag)
        
        viewModel
            .credits
            .map { $0.value?.cast ?? [] }
            .asObservable()
            .bind(to: self.castCollectionView.rx.items(cellIdentifier: PersonCollectionViewCell.defaultReuseIdentifier, cellType: PersonCollectionViewCell.self)) {
                (row, person, cell) in
                cell.populate(with: person)
            }.disposed(by: disposeBag)
        
        viewModel
            .credits
            .map { $0.value }
            .drive(onNext: { [weak self] (credits) in
                guard let credits = credits else { return }
                let defaultHeight: CGFloat = 15.0 + TextStyle.filmDetailTitle.font.lineHeight + 140.0
                if credits.cast.count > 0 {
                    self?.castLabel.text = "CAST"
                    self?.castViewHeight.constant = defaultHeight
                } else {
                    self?.castLabel.text = nil
                    self?.castViewHeight.constant = 0.0
                }
                if credits.crew.count > 0 {
                    self?.crewLabel.text = "CREW"
                    self?.crewViewHeight.constant = defaultHeight
                } else {
                    self?.crewLabel.text = nil
                    self?.crewViewHeight.constant = 0.0
                }
                self?.scrollView.layoutIfNeeded()
                UIView.animate(withDuration: 0.2) {
                    self?.videosView.alpha = 1.0
                    self?.creditsView.alpha = 1.0
                }
            }).disposed(by: disposeBag)
        
        viewModel
            .filmDetail
            .map { $0.value?.videos ?? [] }
            .asObservable()
            .bind(to: videosCollectionView.rx.items(cellIdentifier: VideoCollectionViewCell.defaultReuseIdentifier, cellType: VideoCollectionViewCell.self)) {
                (row, video, cell) in
                if let thumbnailURL = video.youtubeThumbnailURL {
                    cell.videoThumbnailImageView.sd_setImage(with: thumbnailURL)
                } else {
                    cell.videoThumbnailImageView.image = nil
                }
            }.disposed(by: disposeBag)
        
        viewModel
            .filmDetail
            .map { $0.value?.videos ?? [] }
            .asObservable()
            .subscribe(onNext: { [weak self] (videos) in
                if videos.count > 0 {
                    self?.videosLabel.text = "VIDEOS"
                    self?.videosViewHeight.constant = 15.0 + TextStyle.filmDetailTitle.font.lineHeight + 100.0
                } else {
                    self?.videosLabel.text = nil
                    self?.videosViewHeight.constant = 0.0
                }
                self?.scrollView.layoutIfNeeded()
            }).disposed(by: self.disposeBag)
        
        videosCollectionView.rx
            .modelSelected(Video.self)
            .subscribe { [weak self] (event) in
                guard let video = event.element else { return }
                self?.play(video: video)
                
            }.disposed(by: self.disposeBag)
    }
    
    // MARK: - Actions handling
    
    fileprivate func play(video: Video) {
        guard let url = video.youtubeURL else { return }
        UIApplication.shared.openURL(url)
    }
}

// MARK: - 

extension FilmDetailsViewController: UICollectionViewDelegate {
    
    // MARK: - UITableViewDelegate functions
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let person: Person = try? collectionView.rx.model(at: indexPath) else { return }
        router.showPerson(person, backgroundImagePath: backgroundImagePath, from: self)
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
