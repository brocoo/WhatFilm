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
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        self.filmTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
    }
    
    // MARK: -
    
    func populate(withPosterPath posterPath: ImagePath?, andTitle title: String) {
        self.filmTitleLabel.text = title
        self.filmPosterImageView.image = nil
        if let posterPath = posterPath {
            self.filmPosterImageView.setImage(fromTMDbPath: posterPath, withSize: .medium, animatedOnce: true)
        }
    }
}

extension FilmCollectionViewCell: NibLoadableView { }

extension FilmCollectionViewCell: ReusableView { }
