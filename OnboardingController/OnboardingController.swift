//
//  OnboardingViewController.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

// MARK: - make onboardingviewcontroller

extension UIViewController {
    
    func onboardingController() -> OnboardingController? {
        var parentViewController = self.parentViewController
        while let validParentViewController = parentViewController {
            
            if let onboardingViewController = validParentViewController as? OnboardingController {
                return onboardingViewController
            } else {
                parentViewController = validParentViewController.parentViewController
            }
        }
        return nil
    }
}

// MARK: - protocol for progress views

protocol OnboardingProgressView {
    
    func setNumberOfViewControllersInOnboarding(numberOfViewControllers:Int)
    func setOnboardingCompletionPercent(percent:CGFloat)
}

// MARK: - protocol for background views

protocol OnboardingAnimatedBackgroundContentView {
    
    func setOnboardingCompletionPercent(percent:CGFloat)
}

// MARK: - protocol for animated content viewcontrollers

protocol OnboardingAnimatedContentViewController {
    
    func setVisibilityPercent(percent:CGFloat)
}

// MARK: -

class OnboardingController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    var pageViewController:UIPageViewController!
    var progressView:UIView?
    var backgroundContentView:UIView?
    var viewControllers:Array<UIViewController> = []
    var disableScrollViewUpdates:Bool = false
    
    init(viewControllers:Array<UIViewController>, backgroundContentView:UIView? = nil, progressView:UIView? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.backgroundContentView = backgroundContentView
        self.progressView = progressView
        self.viewControllers = viewControllers
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(viewControllers:[])
    }
    
    override func loadView() {
        let defaultSize = CGSizeMake(400, 600)
        let view = UIView(frame: CGRectMake(0, 0, defaultSize.width, defaultSize.height))
        view.backgroundColor = UIColor.whiteColor()
        self.view = view
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController.willMoveToParentViewController(self)
        self.addChildViewController(self.pageViewController)
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pageViewController.view)
        
        self.view.addConstraints([
            NSLayoutConstraint(
                item: self.pageViewController.view, attribute: .Top,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Top,
                multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(
                item: self.pageViewController.view, attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Bottom,
                multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(
                item: self.pageViewController.view, attribute: .Leading,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Leading,
                multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(
                item: self.pageViewController.view, attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Trailing,
                multiplier: 1.0, constant: 0.0)
        ])
        
        self.pageViewController.didMoveToParentViewController(self)
        
        self.pageViewController.view.backgroundColor = UIColor.clearColor()
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self

        if let progressView = self.progressView {
            progressView.frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)
            progressView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
            self.view.addSubview(progressView)
        }
        
        if let backgroundContentView = self.backgroundContentView {
            backgroundContentView.translatesAutoresizingMaskIntoConstraints = false
            self.view.insertSubview(backgroundContentView, atIndex: 0)
            
            self.view.addConstraints([
                NSLayoutConstraint(item: backgroundContentView, attribute: .Top, relatedBy: .Equal,
                    toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: backgroundContentView, attribute: .Bottom, relatedBy: .Equal,
                    toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: backgroundContentView, attribute: .Leading, relatedBy: .Equal,
                    toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: backgroundContentView, attribute: .Trailing, relatedBy: .Equal,
                    toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                ])
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstViewController = self.viewControllers.first {
            self.pageViewController.setViewControllers([firstViewController],
                direction: .Forward,
                animated: false,
                completion: nil)
        }
        
        if let animatedProgressView = self.progressView as? OnboardingProgressView {
            animatedProgressView.setNumberOfViewControllersInOnboarding(self.viewControllers.count)
        }
        
        self.installScrollViewDelegate()
        
        if let scrollView = self.pageViewControllerScrollView() {
            self.updatePercentagesWithScrollView(scrollView)
        }
    }
    
    // MARK: -
    
    func installScrollViewDelegate() {
        self.pageViewControllerScrollView()?.delegate = self
    }
    
    func pageViewControllerScrollView() -> UIScrollView? {
        for subview in self.pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
    
    // MARK: -
    
    func moveToNext(animated:Bool = false) {

        if let currentViewController = self.currentViewController() {
            if let nextViewController = self.viewControllerAfterViewController(currentViewController) {
                self.pageViewController.setViewControllers([nextViewController],
                    direction: .Forward,
                    animated: animated,
                    completion: nil)
            }
        }
    }
    
    func moveToPrevious(animated:Bool = false) {

        if let currentViewController = self.currentViewController() {
            if let previousViewController = self.viewControllerBeforeViewController(currentViewController) {
                self.pageViewController.setViewControllers([previousViewController],
                    direction: .Reverse,
                    animated: animated,
                    completion: nil)
            }
        }
    }
    
    // MARK: -
    
    func currentViewController() -> UIViewController? {
        return self.pageViewController.viewControllers?.first
    }
    
    // MARK: -
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

        if disableScrollViewUpdates {
            return
        }
        self.updatePercentagesWithScrollView(scrollView)
    }
    
    func updatePercentagesWithScrollView(scrollView:UIScrollView)
    {
        // update viewcontrollers
        for viewController in self.viewControllers {
            if let visibilityPercent = self.visibilityPercentForViewController(scrollView, viewController: viewController) {
                if let animatedContentViewController = viewController as? OnboardingAnimatedContentViewController {
                    animatedContentViewController.setVisibilityPercent(visibilityPercent)
                }
            }
        }

        // update background, progress
        if let onboardingProgressPercent = self.onboardingProgressPercent(scrollView) {
            if let animatedBackgroundContentView = self.backgroundContentView as? OnboardingAnimatedBackgroundContentView {
                animatedBackgroundContentView.setOnboardingCompletionPercent(onboardingProgressPercent)
            }
            if let animatedProgressView = self.progressView as? OnboardingProgressView {
                animatedProgressView.setOnboardingCompletionPercent(onboardingProgressPercent)
            }
        }
    }
    
    // MARK: -
    
    func onboardingProgressPercent(scrollView:UIScrollView) -> CGFloat? {
        if let currentViewController = self.currentViewController() {
            if let visibilityPercent = visibilityPercentForViewController(scrollView, viewController: currentViewController) {
                if let index = self.indexForViewController(currentViewController) {
                    let numberOfViewControllers = self.numberOfViewControllers()
                    
                    //print("current \(currentViewController.title) \(visibilityPercent) \(index)")
                    
                    let onboardingCompletionPercent = (1.0 / CGFloat(numberOfViewControllers-1)) * (CGFloat(index) + CGFloat(visibilityPercent) - 1.0)
                    return onboardingCompletionPercent
                }
            }
        }
        return nil
    }
    
    
    func visibilityPercentForViewController(scrollView:UIScrollView, viewController:UIViewController) -> CGFloat? {

        if viewController.isViewLoaded() {

            let scrollViewOffsetX = scrollView.contentOffset.x
            let scrollViewWidth = scrollView.frame.size.width
            
            let view = viewController.view!
            
            if(view.superview != nil) {
                let viewOffset = view.convertPoint(CGPointZero, toView: scrollView)
                
                let percent = (scrollViewOffsetX - viewOffset.x) / scrollViewWidth
                let visibilityPercent = percent + 1.0
                
                return visibilityPercent
            }
            
            return nil
        }
        return nil
    }
    
    // MARK: - pageviewcontroller delegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    }
    
    // MARK: - pageviewcontroller datasource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return self.viewControllerAfterViewController(viewController)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return self.viewControllerBeforeViewController(viewController)
    }
    
    // MARK: - rotation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.disableScrollViewUpdates = true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.disableScrollViewUpdates = false
        if let scrollView = self.pageViewControllerScrollView() {
            self.updatePercentagesWithScrollView(scrollView)
        }
    }
    
    // MARK: -
    
    func numberOfViewControllers() -> Int {
        return self.viewControllers.count
    }
    
    func indexForViewController(viewController:UIViewController) -> Int? {
        return self.viewControllers.indexOf(viewController)
    }
    
    func viewControllerBeforeViewController(viewController:UIViewController) -> UIViewController? {
        if let index = self.viewControllers.indexOf(viewController) {
            let previousIndex = index - 1
            if previousIndex >= 0 {
                return self.viewControllers[previousIndex]
            }
        }
        return nil
    }
    
    func viewControllerAfterViewController(viewController:UIViewController) -> UIViewController? {
        if let index = self.viewControllers.indexOf(viewController) {
            let nextIndex = index + 1
            if nextIndex < self.viewControllers.count {
                return self.viewControllers[nextIndex]
            }
        }
        return nil
    }
    
}
