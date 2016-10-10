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

class PersonViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag: DisposeBag = DisposeBag()
    var viewModel: PersonViewModel?
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var personInitialsLabel: UILabel!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personAgeLabel: UILabel!
    @IBOutlet weak var personBiographyLabel: UILabel!
    @IBOutlet weak var filmsCollectionView: UICollectionView!
    
    // MARK: - UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupCollectionView()
        if let viewModel = self.viewModel { self.setupBindings(forViewModel: viewModel) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        self.fakeNavigationBarHeight.constant = self.topLayoutGuide.length
        
        // Adjust scrollview insets based on film title
        let height: CGFloat = self.view.bounds.width / ImageSize.backdropRatio
        self.scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor(commonColor: .grey)
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
        self.personBiographyLabel.apply(style: .bodyDemiBold)
        self.personBiographyLabel.text = nil
    }
    
    fileprivate func setupCollectionView() {
        self.filmsCollectionView.registerReusableCell(FilmCollectionViewCell.self)
        self.filmsCollectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.filmsCollectionView.showsHorizontalScrollIndicator = false
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
            .map({ $0.asCast })
            .bindTo(self.filmsCollectionView.rx.items(cellIdentifier: FilmCollectionViewCell.DefaultReuseIdentifier, cellType: FilmCollectionViewCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.addDisposableTo(self.disposeBag)
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
}

// MARK: -

extension PersonViewController: SegueReachable {
    
    // MARK: - SegueReachable
    
    static var segueIdentifier: String { return "PersonDetail" }
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
