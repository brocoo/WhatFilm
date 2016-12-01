//
//  PushFilmDetailSegue.swift
//  WhatFilm
//
//  Created by Julien Ducret on 01/12/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class PushFilmDetailSegue: UIStoryboardSegue {
    
    // MARK: - Properties

    var startingFrame: CGRect = CGRect.zero
    var posterImage: UIImage?
    
    public static var identifier: String { return "PushFilmDetailSegueIdentifier" }
    
    // MARK: - UIStoryboardSegue
    
    public override func perform() {
        guard let sourceView = self.source.view else { fatalError() }
        
        // Create poster image for animated transition
        let posterImageView: UIImageView = UIImageView(frame: self.startingFrame)
        posterImageView.backgroundColor = UIColor.groupTableViewBackground
        posterImageView.image = self.posterImage
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = posterImageView.bounds
        blurView.alpha = 0.0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        UIApplication.window?.insertSubview(posterImageView, aboveSubview: sourceView)
        posterImageView.addSubview(blurView)
        
        var finalFrame = sourceView.bounds
        finalFrame.size.height = finalFrame.height - self.source.bottomLayoutGuide.length
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            posterImageView.frame = finalFrame
            blurView.alpha = 1.0
        }, completion: { (_) in
            self.source.navigationController?.pushViewController(self.destination, animated: false)
            UIView.animate(withDuration: 0.1, animations: {
                posterImageView.alpha = 0.0
            }, completion: { (_) in
                posterImageView.removeFromSuperview()
            })
        })
    }
}
