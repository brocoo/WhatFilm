//
//  FeaturedTransitionAnimator.swift
//  WhatFilm
//
//  Created by Julien Ducret on 3/29/18.
//  Copyright © 2018 Julien Ducret. All rights reserved.
//

import UIKit

protocol FilmDetailsTransitionable: class {
    
    // MARK: - FilmDetailsTransitionable protocol
    
    var selectedCell: FilmCollectionViewCell? { get }
}

// MARK: -

final class ToFilmDetailsTransitionAnimator: NSObject {
    
    // MARK: - Properties
    
    fileprivate var selectedCell: FilmCollectionViewCell
    fileprivate var sourceView: UIView
    fileprivate var destinationView: UIView
    
    // MARK: - Initializer
    
    init?(from filmDetailsTransitionable: UIViewController & FilmDetailsTransitionable, destinationView: UIView) {
        guard let cell = filmDetailsTransitionable.selectedCell else { return nil }
        self.selectedCell = cell
        self.sourceView = filmDetailsTransitionable.view
        self.destinationView = destinationView
        super.init()
    }
}

// MARK: -

extension ToFilmDetailsTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let posterImageView: UIImageView = {
            let view = UIImageView(frame: selectedCell.convert(selectedCell.bounds, to: sourceView))
            view.backgroundColor = UIColor.groupTableViewBackground
            view.image = selectedCell.filmPosterImageView.image
            return view
        }()
        
        let blurView: UIVisualEffectView = {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            view.frame = posterImageView.bounds
            view.alpha = 0.0
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return view
        }()
        
        posterImageView.addSubview(blurView)
        transitionContext.containerView.addSubview(sourceView)
        transitionContext.containerView.addSubview(destinationView)
        transitionContext.containerView.addSubview(posterImageView)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            posterImageView.frame = transitionContext.containerView.bounds
            blurView.alpha = 1.0
        }, completion: { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        UIView.animate(withDuration: 0.1, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
            posterImageView.alpha = 0.0
        }, completion: { (_) in
            posterImageView.removeFromSuperview()
        })
    }
}
