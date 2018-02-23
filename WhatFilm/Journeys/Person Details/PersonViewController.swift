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

public final class PersonViewController: UIViewController, ReactiveDisposable {
    
    // MARK: - Properties
    
    let disposeBag: DisposeBag = DisposeBag()
    var viewModel: PersonViewModel?
    var backgroundImagePath: Driver<ImagePath>!
    
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
    
    // MARK: - UIViewController life cycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        if let viewModel = self.viewModel { self.setupBindings(forViewModel: viewModel) }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.track(viewContent: "Person Details", ofType: "View")
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fakeNavigationBarHeight.constant = self.topLayoutGuide.length
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
        personNameLabel.text = nil
        personAgeLabel.apply(style: .filmRating)
        personAgeLabel.text = nil
        crewLabel.apply(style: .filmDetailTitle)
        castLabel.apply(style: .filmDetailTitle)
        personBiographyLabel.apply(style: .bodyDemiBold)
        personBiographyLabel.text = nil
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
    
    fileprivate func setupBindings(forViewModel viewModel: PersonViewModel) {
        
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
            .bind(to: crewCollectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.disposed(by: self.disposeBag)
        
        viewModel
            .filmsCredits
            .map({ $0.value?.cast.withoutDuplicates ?? [] })
            .asObservable()
            .bind(to: castCollectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
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
        personAgeLabel.text = age(forPerson: person)
        personBiographyLabel.text = person.biography
    }
    
    public func prePopulate(forPerson person: Person) {
        if let profilePath = person.profilePath {
            self.personInitialsLabel.text = nil
            self.profileImageView.setImage(fromTMDbPath: profilePath, withSize: .big)
        } else {
            self.personInitialsLabel.text = person.initials
            self.profileImageView.image = nil
        }
        self.personNameLabel.text = person.name
    }
    
    fileprivate func age(forPerson person: PersonDetail) -> String? {
        guard let birthDate = person.birthDate else { return nil }
        guard let birthDateString = (birthDate as NSDate).formattedDate(with: .medium) else { return nil }
        guard let age = person.age else { return nil }
        if let deathDate = person.deathDate {
            return birthDateString + " - " + (deathDate as NSDate).formattedDate(with: .medium) + " (\(age))"
        } else {
            return birthDateString + " (\(age))"
        }
    }
    
    // MARK: - Navigation handling
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filmDetailsViewController = segue.destination as? FilmDetailsViewController,
            let PushFilmDetailsSegue = segue as? PushFilmDetailsSegue,
            let sender = sender as? CollectionViewSelection,
            let cell = sender.collectionView.cellForItem(at: sender.indexPath) as? FilmCollectionViewCell {
            do {
                let film: Film = try sender.collectionView.rx.model(at: sender.indexPath)
                self.preparePushTransition(to: filmDetailsViewController, with: film, fromCell: cell, via: PushFilmDetailsSegue)
                Analytics.track(viewContent: "Selected film", ofType: "Film", withId: "\(film.id)", withAttributes: ["Title": film.fullTitle])
            } catch { fatalError(error.localizedDescription) }
        }
    }
}

// MARK: -

extension PersonViewController: SegueReachable {
    
    // MARK: - SegueReachable
    
    static var segueIdentifier: String { return PushPersonSegue.identifier }
}

// MARK: -

extension PersonViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate functions
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sender = CollectionViewSelection(collectionView: collectionView, indexPath: indexPath)
        self.performSegue(withIdentifier: FilmDetailsViewController.segueIdentifier, sender: sender)
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

extension PersonViewController: FilmDetailsFromCellTransitionable {}
