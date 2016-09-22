//
//  FilmCollectionViewCell.swift
//  WhatFilm
//
//  Created by Julien Ducret on 21/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

class FilmCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var filmTitleLabel: UILabel!

    // MARK: - UICollectionViewCell life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.groupTableViewBackground
        self.filmTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
    }
    
    // MARK: -
    
    func populate(withFilm film: Film) {
        self.filmTitleLabel.text = film.fullTitle
    }
}

extension FilmCollectionViewCell: NibLoadableView { }

extension FilmCollectionViewCell: ReusableView { }
