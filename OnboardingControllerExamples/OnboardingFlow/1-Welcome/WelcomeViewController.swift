//
//  WelcomeViewController.swift
//  OnboardingControllerExamples
//
//  Created by Daniel Langh on 15/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet var button: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // show the onboarding background by making our view transparent
        view.backgroundColor = .clear

        // style the button
        button?.backgroundColor = UIColor.blue
        button?.setTitleColor(UIColor.white, for: .normal)
        button?.layer.cornerRadius = 30.0
    }

    @IBAction func next() {
        self.onboardingController?.moveToNext(true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
