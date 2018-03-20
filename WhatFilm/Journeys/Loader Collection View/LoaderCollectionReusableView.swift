//
//  LoaderCollectionReusableView.swift
//  WhatFilm
//
//  Created by Julien Ducret on 2/25/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import UIKit

final class LoaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Properties
    
    static let height: CGFloat = 85.0
    
    // MARK: - UICollectionReusableView life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        label.apply(style: .placeholder)
        activityIndicatorView.tintColor = TextStyle.placeholder.color
        activityIndicatorView.hidesWhenStopped = true
    }
}

extension LoaderCollectionReusableView: NibLoadableView { }

extension LoaderCollectionReusableView: ReusableView { }
