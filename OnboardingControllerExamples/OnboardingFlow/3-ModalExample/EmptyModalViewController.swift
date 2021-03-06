//
//  ExampleModalViewController.swift
//  OnboardingControllerExamples
//
//  Created by Daniel Langh on 09/04/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

protocol EmptyModalViewControllerDelegate: class {
    func emptyModalViewController(didFinish emptyModalViewController: EmptyModalViewController)
}

class EmptyModalViewController: UIViewController {

    weak var delegate: EmptyModalViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(done))
    }

    // MARK: - User actions

    @objc func done() {
        delegate?.emptyModalViewController(didFinish: self)
    }
}
