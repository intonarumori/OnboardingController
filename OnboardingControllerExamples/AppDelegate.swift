//
//  AppDelegate.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OnboardingControllerDelegate {

    var window: UIWindow?
    var navigationController:UINavigationController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()

        let onboardingController = self.createMainOnboardingControllerExample()
        onboardingController.delegate = self
        
        // create a UINavigationController so we can transition to the examples list later
        let navigationController = UINavigationController(rootViewController: onboardingController)
        navigationController.navigationBarHidden = true
        self.navigationController = navigationController

        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func createMainOnboardingControllerExample() -> OnboardingController {

        let progressView = PagingProgressView()
        progressView.skipButton.addTarget(self, action: #selector(skipOnboarding), forControlEvents: .TouchUpInside)
        
        let onboardingController = OnboardingController(
            viewControllers: [
                //UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Example1"),
                WelcomeViewController(),
                LocationSharingViewController(),
                ModalExampleViewController(),
                BackgroundDescriptionViewController(),
                PagingProgressViewDescriptionViewController()
            ],
            backgroundContentView: ParallaxImageBackgroundView(image: UIImage(named:"PanoramaTopBlur.jpg")!),
            progressView: progressView
        )
        return onboardingController
    }
    
    func skipOnboarding() {
        // replace the onboardingcontroller with the example list
        self.navigationController?.setViewControllers([ExamplesViewController()], animated: true)
    }
    
    // MARK: -
    
    func onboardingController(onboardingController: OnboardingController, didScrollToViewController viewController: UIViewController) {
        // whenever onboardingcontroller scrolls and stops at a viewcontroller, this delegate method will be called
        // print("OnboardingController did scroll to viewController: \(viewController)")
    }
    
    func onboardingControllerDidFinish(onboardingController: OnboardingController) {
        self.skipOnboarding()
    }
}

