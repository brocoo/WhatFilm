//
//  PushPersonDetailsSegue.swift
//  WhatFilm
//
//  Created by Julien Ducret on 08/12/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import RxSwift

// MARK: -

public protocol PersonFromCellTransitionable: class {
    
    func preparePushTransition(to viewController: PersonViewController, with person: Person, fromCell cell: PersonCollectionViewCell, andBackgroundImagePath path: Observable<ImagePath?>, via segue: PushPersonSegue)
}

extension PersonFromCellTransitionable where Self: UIViewController {
    
    public func preparePushTransition(to viewController: PersonViewController, with person: Person, fromCell cell: PersonCollectionViewCell, andBackgroundImagePath path: Observable<ImagePath?> = Observable.empty(), via segue: PushPersonSegue) {
        
        // Create the view model
        let personViewModel = PersonViewModel(withPersonId: person.id)
        viewController.viewModel = personViewModel
        
        // Prepopulate with the selected person
        if let reactiveDisposable = self as? ReactiveDisposable {
            viewController.rx.viewDidLoad.subscribe(onNext: { _ in
                viewController.prePopulate(forPerson: person)
            }).disposed(by: reactiveDisposable.disposeBag)
        }
        
        viewController.backgroundImagePath = path

        // Setup the segue for transition
        segue.startingFrame = cell.convert(cell.bounds, to: self.view)
        segue.profileImage = cell.profileImageView.image
    }
}

// MARK: -

public final class PushPersonSegue: UIStoryboardSegue {
    
    // MARK: - Properties
    
    var startingFrame: CGRect = CGRect.zero
    var profileImage: UIImage?
    
    public static var identifier: String { return "PushPersonSegueIdentifier" }
    
    // MARK: - UIStoryboardSegue
    
    public override func perform() {

        // TODO: - Implement custom segue transition
        
    }
}
