//
//  PersonCollectionViewCell.swift
//  WhatFilm
//
//  Created by Julien Ducret on 06/10/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class PersonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileInitialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - UICollectionViewCell life cycle

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.roleLabel.apply(style: .bodyTinyBold)
        self.containerView.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        self.containerView.layer.cornerRadius = 40.0
        self.containerView.layer.masksToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileInitialsLabel.apply(style: .placeholder)
        self.nameLabel.apply(style: .bodyTiny)
    }
    
    // MARK: - Data handling
    
    public func populate(with person: Person) {
        self.roleLabel.text = person.role
        self.profileInitialsLabel.text = person.initials.uppercased()
        self.profileImageView.image = nil
        if let profilePath = person.profilePath {
            self.profileImageView.setImage(fromTMDbPath: profilePath, withSize: .medium)
        }
        self.nameLabel.text = person.name
    }
}

extension PersonCollectionViewCell: NibLoadableView { }

extension PersonCollectionViewCell: ReusableView { }
