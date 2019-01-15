//
//  PersonViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 10/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PersonViewController: UIViewController, ReactiveDisposable {
    
    // MARK: - Properties
    
    let disposeBag: DisposeBag = DisposeBag()
    private let backgroundImagePath: Driver<ImagePath>
    private let viewModel: PersonViewModel
    private let router: Router
    fileprivate(set) var selectedCell: FilmCollectionViewCell?
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var fakeNavigationBar: UIView!
    @IBOutlet weak var fakeNavigationBarHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var personInitialsLabel: UILabel!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personAgeLabel: UILabel!
    @IBOutlet weak var crewView: UIView!
    @IBOutlet weak var crewViewHeight: NSLayoutConstraint!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var crewCollectionView: UICollectionView!
    @IBOutlet weak var castView: UIView!
    @IBOutlet weak var castViewHeight: NSLayoutConstraint!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var personBiographyLabel: UILabel!
    
    // MARK: - Initializer
    
    init(viewModel: PersonViewModel, backgroundImagePath: Driver<ImagePath>, router: Router) {
        self.viewModel = viewModel
        self.backgroundImagePath = backgroundImagePath
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // MARK: - UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupBindings()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.track(viewContent: "Person Details", ofType: "View")
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fakeNavigationBarHeight.constant = view.safeAreaInsets.top
//        self.fakeNavigationBarHeight.constant = self.topLayoutGuide.length
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        fakeNavigationBar.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        profileImageContainerView.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        profileImageContainerView.layer.cornerRadius = 50.0
        profileImageContainerView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        personInitialsLabel.apply(style: .bodySmall)
        personInitialsLabel.text = nil
        personNameLabel.apply(style: .filmDetailTitle)
        personNameLabel.text = viewModel.person.name
        personAgeLabel.apply(style: .filmRating)
        personAgeLabel.text = nil
        crewLabel.apply(style: .filmDetailTitle)
        castLabel.apply(style: .filmDetailTitle)
        personBiographyLabel.apply(style: .bodyDemiBold)
        personBiographyLabel.text = nil
        if let profilePath = viewModel.person.profilePath {
            personInitialsLabel.text = nil
            profileImageView.setImage(fromTMDbPath: profilePath, withSize: .big)
        } else {
            personInitialsLabel.text = viewModel.person.initials
            profileImageView.image = nil
        }
    }
    
    fileprivate func setupCollectionView() {
        crewCollectionView.registerReusableCell(FilmCollectionViewCell.self)
        crewCollectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        crewCollectionView.showsHorizontalScrollIndicator = false
        castCollectionView.registerReusableCell(FilmCollectionViewCell.self)
        castCollectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        castCollectionView.showsHorizontalScrollIndicator = false
    }
    
    // MARK: - Reactive setup
    
    fileprivate func setupBindings() {
        
        viewModel
            .personDetail
            .drive(onNext: { [weak self] (result) in
                guard let personDetail = result.value else { return }
                self?.populate(forPerson: personDetail)
            })
            .disposed(by: self.disposeBag)
        
        viewModel
            .filmsCredits
            .drive(onNext: { [weak self] (result) in
                guard let credits = result.value else { return }
                let defaultHeight: CGFloat = 15.0 + TextStyle.filmDetailTitle.font.lineHeight + 8.0 + 200.0
                if credits.cast.count > 0 {
                    self?.castLabel.text = "APPEARS IN"
                    self?.castViewHeight.constant = defaultHeight
                } else {
                    self?.castLabel.text = nil
                    self?.castViewHeight.constant = 0.0
                }
                if credits.crew.count > 0 {
                    self?.crewLabel.text = "WORKED ON"
                    self?.crewViewHeight.constant = defaultHeight
                } else {
                    self?.crewLabel.text = nil
                    self?.crewViewHeight.constant = 0.0
                }
                self?.scrollView.layoutIfNeeded()
            })
            .disposed(by: self.disposeBag)
        
        viewModel
            .filmsCredits
            .map({ $0.value?.crew.withoutDuplicates ?? [] })
            .asObservable()
            .bind(to: crewCollectionView.rx.items(cellIdentifier: FilmCollectionViewCell.defaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.disposed(by: self.disposeBag)
        
        viewModel
            .filmsCredits
            .map({ $0.value?.cast.withoutDuplicates ?? [] })
            .asObservable()
            .bind(to: castCollectionView.rx.items(cellIdentifier: FilmCollectionViewCell.defaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.disposed(by: self.disposeBag)
        
        backgroundImagePath
            .drive(onNext: { [weak self] (imagePath) in
                self?.blurredImageView.setImage(fromTMDbPath: imagePath, withSize: .medium)
            }).disposed(by: self.disposeBag)
    }
    
    // MARK: - Data handling
    
    fileprivate func populate(forPerson person: PersonDetail) {
        personInitialsLabel.text = person.initials
        profileImageView.image = nil
        if let profilePath = person.profilePath {
            profileImageView.setImage(fromTMDbPath: profilePath, withSize: .big)
        }
        personNameLabel.text = person.name
        personAgeLabel.text = person.birthDeathYearsAndAgeFormatted
        personBiographyLabel.text = person.biography
    }
}

// MARK: -

extension PersonViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate functions
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let film: Film = try? collectionView.rx.model(at: indexPath) else { return }
        selectedCell = collectionView.cellForItem(at: indexPath) as? FilmCollectionViewCell
        router.showFilmDetails(for: film, from: self)
    }
}

// MARK: -

extension PersonViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.height * ImageSize.posterRatio
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
}

// MARK: -

extension PersonViewController: FilmDetailsTransitionable {
    
    // MARK: - FilmDetailsTransitionable
}
