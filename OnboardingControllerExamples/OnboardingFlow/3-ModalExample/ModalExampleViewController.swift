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
        self.view.backgroundColor = UIColor.clearColor()
        
        // style the buttons
        self.skipButton?.backgroundColor = UIColor.blueColor()
        self.skipButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.skipButton?.layer.cornerRadius = 30.0
        
        
        self.modalButton?.backgroundColor = UIColor.blueColor()
        self.modalButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
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
        self.presentViewController(navigationController, animated: true, completion: nil)
    }

    // MARK: EmptyModalViewController delegate
    
    func emptyModalViewController(didFinish exampleModalViewController: EmptyModalViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
