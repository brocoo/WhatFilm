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
    var backgroundImagePath: Observable<ImagePath?> = Observable.empty()
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var fakeNavigationBar: UIView!
    @IBOutlet weak var fakeNavigationBarHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var personInitialsLabel: UILabel!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personAgeLabel: UILabel!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var crewCollectionView: UICollectionView!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var personBiographyLabel: UILabel!
    
    // MARK: - UIViewController life cycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupCollectionView()
        if let viewModel = self.viewModel { self.setupBindings(forViewModel: viewModel) }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fakeNavigationBarHeight.constant = self.topLayoutGuide.length
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        self.fakeNavigationBar.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        self.profileImageView.layer.cornerRadius = 50.0
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.backgroundColor = UIColor.groupTableViewBackground
        self.personInitialsLabel.apply(style: .bodySmall)
        self.personInitialsLabel.text = nil
        self.personNameLabel.apply(style: .filmDetailTitle)
        self.personNameLabel.text = nil
        self.personAgeLabel.apply(style: .filmRating)
        self.personAgeLabel.text = nil
        self.crewLabel.apply(style: .filmDetailTitle)
        self.castLabel.apply(style: .filmDetailTitle)
        self.personBiographyLabel.apply(style: .bodyDemiBold)
        self.personBiographyLabel.text = nil
    }
    
    fileprivate func setupCollectionView() {
        self.crewCollectionView.registerReusableCell(FilmCollectionViewCell.self)
        self.crewCollectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.crewCollectionView.showsHorizontalScrollIndicator = false
        self.castCollectionView.registerReusableCell(FilmCollectionViewCell.self)
        self.castCollectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.castCollectionView.showsHorizontalScrollIndicator = false
    }
    
    // MARK: - Reactive setup
    
    fileprivate func setupBindings(forViewModel viewModel: PersonViewModel) {
        viewModel
            .personDetail
            .subscribe(onNext: { [unowned self] (personDetail) in
                self.populate(forPerson: personDetail)
            })
            .addDisposableTo(self.disposeBag)
        
        viewModel
            .filmsCredits
            .map({ $0.asCrew })
            .bindTo(self.crewCollectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.addDisposableTo(self.disposeBag)
        
        viewModel
            .filmsCredits
            .map({ $0.asCast })
            .bindTo(self.castCollectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.addDisposableTo(self.disposeBag)
        
        self.backgroundImagePath
            .subscribe(onNext: { [unowned self] (imagePath) in
                if let imagePath = imagePath {
                    self.blurredImageView.setImage(fromTMDbPath: imagePath, withSize: .medium)
                } else {
                    self.blurredImageView.image = nil
                }
            }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Data handling
    
    fileprivate func populate(forPerson person: PersonDetail) {
        if let profilePath = person.profilePath {
            self.personInitialsLabel.text = nil
            self.profileImageView.setImage(fromTMDbPath: profilePath, withSize: .big)
        } else {
            self.personInitialsLabel.text = person.initials
            self.profileImageView.image = nil
        }
        self.personNameLabel.text = person.name
        self.personAgeLabel.text = self.age(forPerson: person)
        self.personBiographyLabel.text = person.biography
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
        guard let birthDate = person.birthdate else { return nil }
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
                let film: Film = try sender.collectionView.rx.model(sender.indexPath)
                self.preparePushTransition(to: filmDetailsViewController, with: film, fromCell: cell, via: PushFilmDetailsSegue)
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
