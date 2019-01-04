//
//  ModalExampleViewController.swift
//  OnboardingControllerExamples
//
//  Created by Daniel Langh on 09/04/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

class ModalExampleViewController: UIViewController, EmptyModalViewControllerDelegate {

    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var modalButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // show the onboarding background by making our view transparent
        view.backgroundColor = UIColor.clear

        // style the buttons
        skipButton.backgroundColor = .blue
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.layer.cornerRadius = 30.0

        modalButton.backgroundColor = .blue
        modalButton.setTitleColor(.white, for: .normal)
        modalButton.layer.cornerRadius = 30.0
    }

    // MARK: - user actions

    @IBAction func next() {
        onboardingController?.moveToNext(true)
    }

    // MARK: - modal viewcontroller presentation

    @IBAction func showModal() {
        let exampleModalViewController = EmptyModalViewController()
        let navigationController = UINavigationController(rootViewController: exampleModalViewController)
        exampleModalViewController.delegate = self
        present(navigationController, animated: true, completion: nil)
    }

    // MARK: - EmptyModalViewController delegate

    func emptyModalViewController(didFinish exampleModalViewController: EmptyModalViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
