//
//  FilmDetailsViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 28/09/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

final class FilmDetailsViewController: UIViewController {

    // MARK: - Properties
    
    var viewModel: FilmDetailsViewModel!
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    // MARK: - UIViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FilmDetailsViewController: SegueReachable {
    
    static var segueIdentifier: String { return "FilmDetails" }
}
