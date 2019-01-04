//
//  ModalExampleViewController.swift
//  OnboardingControllerExamples
//
//  Created by Daniel Langh on 09/04/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

class ModalExampleViewController: UIViewController, EmptyModalViewControllerDelegate {
    
    @IBOutlet var bodyLabel:UILabel?
    @IBOutlet var skipButton:UIButton?
    @IBOutlet var modalButton:UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show the onboarding background by making our view transparent
        self.view.backgroundColor = UIColor.clear
        
        // style the buttons
        self.skipButton?.backgroundColor = UIColor.blue
        self.skipButton?.setTitleColor(UIColor.white, for: .normal)
        self.skipButton?.layer.cornerRadius = 30.0
        
        
        self.modalButton?.backgroundColor = UIColor.blue
        self.modalButton?.setTitleColor(UIColor.white, for: .normal)
        self.modalButton?.layer.cornerRadius = 30.0
    }
    
    // MARK: user actions
    
    @IBAction func next() {
        self.onboardingController?.moveToNext(true)
    }
    
    // MARK: modal viewcontroller presentation
    
    @IBAction func showModal() {
        let exampleModalViewController = EmptyModalViewController()
        let navigationController = UINavigationController(rootViewController: exampleModalViewController)
        exampleModalViewController.delegate = self
        self.present(navigationController, animated: true, completion: nil)
    }

    // MARK: EmptyModalViewController delegate
    
    func emptyModalViewController(didFinish exampleModalViewController: EmptyModalViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
