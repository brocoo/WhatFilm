//
//  PushFilmDetailsSegue.swift
//  WhatFilm
//
//  Created by Julien Ducret on 01/12/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

// MARK: -

public protocol FilmDetailsFromCellTransitionable: class {
    
    func preparePushTransition(to viewController: FilmDetailsViewController, with film: Film, fromCell cell: FilmCollectionViewCell, via segue: PushFilmDetailsSegue)
}

extension FilmDetailsFromCellTransitionable where Self: UIViewController {
    
    public func preparePushTransition(to viewController: FilmDetailsViewController, with film: Film, fromCell cell: FilmCollectionViewCell, via segue: PushFilmDetailsSegue) {
        
        // Create the view model
        let filmDetailViewModel = FilmDetailsViewModel(withFilmId: film.id)
        viewController.viewModel = filmDetailViewModel
        
        // Prepopulate with the selected film
        if let reactiveDisposable = self as? ReactiveDisposable {
            viewController.rx.viewDidLoad.subscribe(onNext: { _ in
                viewController.prePopulate(forFilm: film)
            }).addDisposableTo(reactiveDisposable.disposeBag)
        }
        
        // Setup the segue for transition
        segue.startingFrame = cell.convert(cell.bounds, to: self.view)
        segue.posterImage = cell.filmPosterImageView.image
    }
}

// MARK: -

public final class PushFilmDetailsSegue: UIStoryboardSegue {
    
    // MARK: - Properties

    var startingFrame: CGRect = CGRect.zero
    var posterImage: UIImage?
    
    public static var identifier: String { return "PushFilmDetailSegueIdentifier" }
    
    // MARK: - UIStoryboardSegue
    
    public override func perform() {
        guard let sourceView = self.source.view else { fatalError() }
        
        // Create overlaying poster image for animated transition
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
        
        self.source.navigationController?.pushViewController(self.destination, animated: false)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            posterImageView.frame = finalFrame
            blurView.alpha = 1.0
        }, completion: { (_) in

        })
        UIView.animate(withDuration: 0.1, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
            posterImageView.alpha = 0.0
        }, completion: { (_) in
            posterImageView.removeFromSuperview()
        })
    }
}
