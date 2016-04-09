//
//  ExampleModalViewController.swift
//  OnboardingControllerExamples
//
//  Created by Daniel Langh on 09/04/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

protocol EmptyModalViewControllerDelegate: class {
    func emptyModalViewController(didFinish emptyModalViewController:EmptyModalViewController)
}

class EmptyModalViewController: UIViewController {

    weak var delegate:EmptyModalViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("done"))
    }

    // MARK: User actions
    
    func done() {
        self.delegate?.emptyModalViewController(didFinish: self)
    }
}
