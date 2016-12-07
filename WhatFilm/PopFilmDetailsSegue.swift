//
//  PopFilmDetailsSegue.swift
//  WhatFilm
//
//  Created by Julien Ducret on 02/12/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit

public final class PopFilmDetailsSegue: UIStoryboardSegue {
    
    // MARK: - Properties
    
    public static var identifier: String { return "PopFilmDetailSegueIdentifier" }
    
    // MARK: - UIStoryboardSegue
    
    public override func perform() {
        guard let sourceView = self.source.view else { fatalError() }
        guard let destinationView = self.source.view else { fatalError() }
        
        let finalFrame = sourceView.bounds.insetBy(dx: 30.0, dy: 30.0)
        UIApplication.window?.insertSubview(destinationView, belowSubview: sourceView)
        
        self.source.navigationController?.pushViewController(self.destination, animated: false)
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            sourceView.frame = finalFrame
            destinationView.alpha = 1.0
        }, completion: { (_) in
            let _ = self.source.navigationController?.popViewController(animated: false)
//            destinationView.removeFromSuperview()
        })
    }
}
