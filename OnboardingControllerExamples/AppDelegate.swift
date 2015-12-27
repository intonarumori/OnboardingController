//
//  AppDelegate.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController:UINavigationController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()

        let onboardingController = self.createOnboardingController()
        let navigationController = UINavigationController(rootViewController: onboardingController)
        navigationController.navigationBarHidden = true
        self.navigationController = navigationController

        self.window?.rootViewController = navigationController
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func createOnboardingController() -> OnboardingController {

        let progressView = PagingProgressView()
        progressView.skipButton.addTarget(self, action: Selector("jumpToExamples"), forControlEvents: .TouchUpInside)
        
        let onboardingController = OnboardingController(
            viewControllers: [
                WelcomeViewController(),
                LocationSharingViewController(),
                BackgroundDescriptionViewController(),
                PagingProgressViewDescriptionViewController()
            ],
            backgroundContentView: ParallaxImageBackgroundView(image: UIImage(named:"PanoramaTopBlur.jpg")!),
            progressView: progressView
        )
        return onboardingController
    }
    
    func jumpToExamples() {
        self.navigationController?.setViewControllers([ExamplesViewController()], animated: true)
    }
}

