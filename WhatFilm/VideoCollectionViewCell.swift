//
//  VideoCollectionViewCell.swift
//  WhatFilm
//
//  Created by Julien Ducret on 07/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    static let imageRatio: CGFloat = 480 / 360
    
    // MARK: - UICollectionViewCell life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    fileprivate func setupUI() {
        self.videoThumbnailImageView.backgroundColor = UIColor(commonColor: .grey)
        self.videoThumbnailImageView.contentMode = .scaleAspectFill
    }
}

extension VideoCollectionViewCell: NibLoadableView { }

extension VideoCollectionViewCell: ReusableView { }
