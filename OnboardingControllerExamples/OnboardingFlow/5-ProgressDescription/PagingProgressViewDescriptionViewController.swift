//
//  PagingProgressViewDescriptionViewController.swift
//  OnboardingControllerExamples
//
//  Created by Daniel Langh on 15/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

class PagingProgressViewDescriptionViewController: UIViewController {

    @IBOutlet var button:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show the onboarding background by making our view transparent
        self.view.backgroundColor = UIColor.clearColor()
        
        // style the button
        self.button?.backgroundColor = UIColor.blueColor()
        self.button?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.button?.layer.cornerRadius = 30.0
    }
    
    @IBAction func next() {
        self.onboardingController?.moveToNext(true)
    }
}
