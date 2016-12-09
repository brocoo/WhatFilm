//
//  FilmCollectionViewCell.swift
//  WhatFilm
//
//  Created by Julien Ducret on 21/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class FilmCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var filmPosterImageView: UIImageView!

    // MARK: - UICollectionViewCell life cycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.filmPosterImageView.backgroundColor = UIColor.white
        self.filmTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
    }
    
    // MARK: -
    
    func populate(withPosterPath posterPath: ImagePath?, andTitle title: String) {
        if let posterPath = posterPath {
            self.filmTitleLabel.text = nil
            self.filmTitleLabel.alpha = 0.0
            self.filmPosterImageView.setImage(fromTMDbPath: posterPath, withSize: .medium, animated: true)
            self.filmPosterImageView.alpha = 1.0
        } else {
            self.filmTitleLabel.text = title
            self.filmTitleLabel.alpha = 1.0
            self.filmPosterImageView.image = nil
            self.filmPosterImageView.alpha = 0.25
        }
    }
}

extension FilmCollectionViewCell: NibLoadableView { }

extension FilmCollectionViewCell: ReusableView { }
