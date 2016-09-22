//
//  FilmTableViewCell.swift
//  WhatFilm
//
//  Created by Julien Ducret on 14/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

class FilmTableViewCell: UITableViewCell {

    // MARK: - IBOutlet properties
    
    @IBOutlet weak var filmTitleLabel: UILabel!
    
    // MARK: - UITableViewCell life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: -
    
    func populate(withFilm film: Film) {
        self.filmTitleLabel.text = film.fullTitle
    }
}

extension FilmTableViewCell: NibLoadableView { }

extension FilmTableViewCell: ReusableView { }
