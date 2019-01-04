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
    var navigationController: UINavigationController?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white

        let onboardingController = self.createMainOnboardingControllerExample()
        onboardingController.delegate = self

        // create a UINavigationController so we can transition to the examples list later
        let navigationController = UINavigationController(rootViewController: onboardingController)
        navigationController.isNavigationBarHidden = true
        self.navigationController = navigationController

        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        return true
    }

    func createMainOnboardingControllerExample() -> OnboardingController {

        let progressView = PagingProgressView()
        progressView.skipButton.addTarget(self, action: #selector(skipOnboarding), for: .touchUpInside)

        let onboardingController = OnboardingController(
            viewControllers: [
                //UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Example1"),
                UIStoryboard(name: "OnboardingFlow", bundle: nil)
                    .instantiateViewController(withIdentifier: "WelcomeViewController"),
                LocationSharingViewController(),
                ModalExampleViewController(),
                BackgroundDescriptionViewController(),
                PagingProgressViewDescriptionViewController()
            ],
            backgroundContentView: ParallaxImageBackgroundView(image: UIImage(named: "PanoramaTopBlur.jpg")!),
            progressView: progressView
        )
        return onboardingController
    }

    @objc func skipOnboarding() {
        // replace the onboardingcontroller with the example list
        self.navigationController?.setViewControllers([ExamplesViewController()], animated: true)
    }

    // MARK: -

    func onboardingController(_ onboardingController: OnboardingController,
                              didScrollToViewController viewController: UIViewController) {
        // whenever onboardingcontroller scrolls and stops at a viewcontroller, this delegate method will be called
        // print("OnboardingController did scroll to viewController: \(viewController)")
    }

    func onboardingControllerDidFinish(_ onboardingController: OnboardingController) {
        self.skipOnboarding()
    }
}
