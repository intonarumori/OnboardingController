//
//  OnboardingViewController.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

// MARK: - UIViewController extension

internal extension UIViewController {
    
    /**
     Returns the parent `OnboardingController` if the view controller is part of an onboarding flow.
     (usage is similar to accessing `UINavigationController` from any `UIViewController`)
     
     - returns: the parent `OnboardingController` if the view controller is part of an onboarding flow
     */
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

// MARK: - OnboardingController progress view protocol

public protocol OnboardingProgressView {
    
    func setNumberOfViewControllersInOnboarding(numberOfViewControllers:Int)
    func setOnboardingCompletionPercent(percent:CGFloat)
}

// MARK: - OnboardingController background view protocol

public protocol OnboardingAnimatedBackgroundContentView {
    
    func setOnboardingCompletionPercent(percent:CGFloat)
}

// MARK: - protocol for animated content viewcontrollers

public protocol OnboardingContentViewController {

    /**
     Returns the parent OnboardingController if the viewcontroller is part of an onboarding flow.
     (usage is similar to accessing UINavigationController from any UIViewController)
     
     - parameter percent: the value of visilibity percentage. Valid values are in the [0.0, 2.0] range. Value of 0.0 means the viewcontroller is not yet visible and will come from the right, 1.0 means the viewcontroller is in the center and fully visible, while 2.0 means the viewcontroller is not visible any more and has been scrolled out of visibility and is located on the left.
     */
    func setVisibilityPercent(percent:CGFloat)
}

// MARK: - OnboardingController delegate protocol

public protocol OnboardingControllerDelegate : class {
    func onboardingController(onboardingController:OnboardingController, didScrollToViewController viewController:UIViewController)
    func onboardingControllerDidFinish(onboardingController:OnboardingController)
}

// MARK: -

public class OnboardingController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    public weak var delegate:OnboardingControllerDelegate?
    
    public private(set) var progressView:UIView?
    public private(set) var backgroundContentView:UIView?
    public private(set) var viewControllers:Array<UIViewController> = []
    
    private var scrollViewUpdatesEnabled:Bool = true
    public private(set) var pageViewController:UIPageViewController!
    
    init(viewControllers:Array<UIViewController>, backgroundContentView:UIView? = nil, progressView:UIView? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.backgroundContentView = backgroundContentView
        self.progressView = progressView
        self.viewControllers = viewControllers
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(viewControllers:[])
    }
    
    public override func loadView() {
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
            let progressViewHeight = progressView.frame.size.height
            progressView.frame = CGRectMake(0, self.view.bounds.size.height-progressViewHeight, self.view.bounds.size.width, progressViewHeight)
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
    
    public override func viewDidLoad() {
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
    
    private func installScrollViewDelegate() {
        self.pageViewControllerScrollView()?.delegate = self
    }
    
    private func pageViewControllerScrollView() -> UIScrollView? {
        for subview in self.pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
    
    // MARK: -
    
    public func moveToNext(animated:Bool = false) {

        if let currentViewController = self.currentViewController() {
            if let nextViewController = self.viewControllerAfterViewController(currentViewController) {
                self.pageViewController.setViewControllers([nextViewController],
                    direction: .Forward,
                    animated: animated,
                    completion:{ (finished) -> Void in
                        if finished {
                            self.sendDidScrollToViewControllerNotification()
                        }
                })
            } else {
                if let delegate = self.delegate {
                    delegate.onboardingControllerDidFinish(self)
                }
            }
        }
    }
    
    public func moveToPrevious(animated:Bool = false) {

        if let currentViewController = self.currentViewController() {
            if let previousViewController = self.viewControllerBeforeViewController(currentViewController) {
                self.pageViewController.setViewControllers([previousViewController],
                    direction: .Reverse,
                    animated: animated,
                    completion:{ (finished) -> Void in
                        if finished {
                            self.sendDidScrollToViewControllerNotification()
                        }
                })
            }
        }
    }
    
    // MARK: -
    
    private func currentViewController() -> UIViewController? {
        return self.pageViewController.viewControllers?.first
    }
    
    // MARK: -
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {

        guard scrollViewUpdatesEnabled else {
            return
        }
        self.updatePercentagesWithScrollView(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollFinished(scrollView)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollFinished(scrollView)
        }
    }
    
    private func scrollFinished(scrollView:UIScrollView) {
        self.sendDidScrollToViewControllerNotification()
    }
    
    private func sendDidScrollToViewControllerNotification() {
        if let delegate = self.delegate {
            if let currentViewController = self.currentViewController() {
                delegate.onboardingController(self, didScrollToViewController: currentViewController)
            }
        }
    }
    
    private func updatePercentagesWithScrollView(scrollView:UIScrollView)
    {
        // update viewcontrollers
        for viewController in self.viewControllers {
            if let visibilityPercent = self.visibilityPercentForViewController(scrollView, viewController: viewController) {
                if let animatedContentViewController = viewController as? OnboardingContentViewController {
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
    
    private func onboardingProgressPercent(scrollView:UIScrollView) -> CGFloat? {
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
    
    
    private func visibilityPercentForViewController(scrollView:UIScrollView, viewController:UIViewController) -> CGFloat? {

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
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
    
    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    }
    
    // MARK: - pageviewcontroller datasource
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return self.viewControllerAfterViewController(viewController)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return self.viewControllerBeforeViewController(viewController)
    }
    
    // MARK: - rotation
    
    public override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.scrollViewUpdatesEnabled = false
    }
    
    public override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.scrollViewUpdatesEnabled = true
        if let scrollView = self.pageViewControllerScrollView() {
            self.updatePercentagesWithScrollView(scrollView)
        }
    }
    
    // MARK: -
    
    private func numberOfViewControllers() -> Int {
        return self.viewControllers.count
    }
    
    private func indexForViewController(viewController:UIViewController) -> Int? {
        return self.viewControllers.indexOf(viewController)
    }
    
    private func viewControllerBeforeViewController(viewController:UIViewController) -> UIViewController? {
        if let index = self.viewControllers.indexOf(viewController) {
            let previousIndex = index - 1
            if previousIndex >= 0 {
                return self.viewControllers[previousIndex]
            }
        }
        return nil
    }
    
   private func viewControllerAfterViewController(viewController:UIViewController) -> UIViewController? {
        if let index = self.viewControllers.indexOf(viewController) {
            let nextIndex = index + 1
            if nextIndex < self.viewControllers.count {
                return self.viewControllers[nextIndex]
            }
        }
        return nil
    }
}
