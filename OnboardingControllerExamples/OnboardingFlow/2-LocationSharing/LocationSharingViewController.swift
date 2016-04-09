//
//  LocationSharingViewController.swift
//  OnboardingControllerExamples
//
//  Created by Daniel Langh on 15/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

class LocationSharingViewController: UIViewController {

    @IBOutlet var bodyLabel:UILabel?
    @IBOutlet var skipButton:UIButton?
    @IBOutlet var locationButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show the onboarding background by making our view transparent
        self.view.backgroundColor = UIColor.clearColor()
        
        // style the buttons
        self.skipButton?.backgroundColor = UIColor.blueColor()
        self.skipButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.skipButton?.layer.cornerRadius = 30.0


        self.locationButton?.backgroundColor = UIColor.blueColor()
        self.locationButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.locationButton?.layer.cornerRadius = 30.0
    }
    
    @IBAction func requestLocationAccess() {
        // put your custom code here to request location access
        // for the sake of simplicity we use an alert here for this example
        
        let alertController = UIAlertController(title: "Location alert example", message: "Implement your location request logic in your custom viewcontroller", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction( UIAlertAction(title: "OK", style: .Default, handler: nil))
    
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - User action
    
    @IBAction func next() {
        self.onboardingController?.moveToNext(true)
    }
}
