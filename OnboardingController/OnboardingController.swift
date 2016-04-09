//
//  OnboardingViewController.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

// MARK: - UIViewController extension

public extension UIViewController {
    
    /**
     Returns the parent `OnboardingController` if the view controller is part of an onboarding flow.
     (usage is similar to accessing `UINavigationController` from any `UIViewController`)
     
     - returns: the parent `OnboardingController` if the view controller is part of an onboarding flow
     */
    var onboardingController:OnboardingController? {
        get {
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
}

// MARK: - OnboardingController progress view protocol

public protocol OnboardingProgressViewProtocol: class {
    
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
    
    private weak var currentViewController:UIViewController?
    
    private var scrollViewUpdatesEnabled:Bool = true
    public private(set) var pageViewController:UIPageViewController?
    
    public init(viewControllers:Array<UIViewController>, backgroundContentView:UIView? = nil, progressView:UIView? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.backgroundContentView = backgroundContentView
        self.progressView = progressView
        self.viewControllers = viewControllers
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(viewControllers:[])
    }
    
    public override func loadView() {
        let defaultSize = CGSizeMake(400, 600)
        let view = UIView(frame: CGRectMake(0, 0, defaultSize.width, defaultSize.height))
        view.backgroundColor = UIColor.whiteColor()
        self.view = view
        
        let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.willMoveToParentViewController(self)
        self.addChildViewController(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pageViewController.view)
        self.pageViewController = pageViewController
        
        self.view.addConstraints([
            NSLayoutConstraint(
                item: pageViewController.view, attribute: .Top,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Top,
                multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(
                item: pageViewController.view, attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Bottom,
                multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(
                item: pageViewController.view, attribute: .Leading,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Leading,
                multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(
                item: pageViewController.view, attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self.view, attribute: .Trailing,
                multiplier: 1.0, constant: 0.0)
        ])
        
        pageViewController.didMoveToParentViewController(self)
        pageViewController.view.backgroundColor = UIColor.clearColor()
        
        pageViewController.delegate = self
        pageViewController.dataSource = self

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
            self.pageViewController?.setViewControllers([firstViewController],
                direction: .Forward,
                animated: false,
                completion: nil)
        }
        
        if let animatedProgressView = self.progressView as? OnboardingProgressViewProtocol {
            animatedProgressView.setNumberOfViewControllersInOnboarding(self.viewControllers.count)
        }
        
        self.installScrollViewDelegate()
        
        if let scrollView = self.pageViewControllerScrollView() {
            self.updatePercentagesWithScrollView(scrollView, animated: false)
        }
    }
    
    // MARK: -
    
    private func installScrollViewDelegate() {
        self.pageViewControllerScrollView()?.delegate = self
    }
    
    private func pageViewControllerScrollView() -> UIScrollView? {
        
        guard let pageViewController = self.pageViewController else {
            return nil
        }
        
        for subview in pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
    
    // MARK: -
    
    public func moveToNext(animated:Bool = false) {

        guard let pageViewController = self.pageViewController else {
            return
        }

        if let currentViewController = self.currentViewController {
            if let nextViewController = self.viewControllerAfterViewController(currentViewController) {
                pageViewController.setViewControllers([nextViewController],
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

        guard let pageViewController = self.pageViewController else {
            return
        }
        
        if let currentViewController = currentViewController {
            if let previousViewController = self.viewControllerBeforeViewController(currentViewController) {
                pageViewController.setViewControllers([previousViewController],
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
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {

        guard scrollViewUpdatesEnabled else {
            return
        }
        self.updatePercentagesWithScrollView(scrollView, animated: true)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollFinished(scrollView)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollFinished(scrollView)
        } else {
            /*
            UIView.animateWithDuration(0.2) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }*/
        }
    }
    
    private func scrollFinished(scrollView:UIScrollView) {
        self.sendDidScrollToViewControllerNotification()
    }
    
    private func sendDidScrollToViewControllerNotification() {
        if let currentViewController = currentViewController {
            delegate?.onboardingController(self, didScrollToViewController: currentViewController)
        }
    }
    
    private func updatePercentagesWithScrollView(scrollView:UIScrollView, animated:Bool)
    {
        // update viewcontrollers
        
        var currentlyFocusedViewController:UIViewController? = nil
        
        for viewController in self.viewControllers {
            if let visibilityPercent = self.visibilityPercentForViewController(scrollView, viewController: viewController) {
                if let animatedContentViewController = viewController as? OnboardingContentViewController {
                    animatedContentViewController.setVisibilityPercent(visibilityPercent)
                }
                
                if visibilityPercent >= 0.5 && visibilityPercent < 1.5 {
                    currentlyFocusedViewController = viewController
                }
            }
        }
        
        if currentViewController != currentlyFocusedViewController {
            currentViewController = currentlyFocusedViewController
            
            if animated {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.setNeedsStatusBarAppearanceUpdate()
                })
            } else {
                setNeedsStatusBarAppearanceUpdate()
            }
        }

        // update background, progress
        if let onboardingProgressPercent = self.onboardingProgressPercent(scrollView) {
            if let animatedBackgroundContentView = self.backgroundContentView as? OnboardingAnimatedBackgroundContentView {
                animatedBackgroundContentView.setOnboardingCompletionPercent(onboardingProgressPercent)
            }
            if let animatedProgressView = self.progressView as? OnboardingProgressViewProtocol {
                animatedProgressView.setOnboardingCompletionPercent(onboardingProgressPercent)
            }
        }
    }
    
    // MARK: -
    
    private func onboardingProgressPercent(scrollView:UIScrollView) -> CGFloat? {
        if let currentViewController = currentViewController {
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
        print("pageViewController didFinishAnimating")
    }
    
    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        print("pageViewController willTransitionToViewControllers", pendingViewControllers)
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
            self.updatePercentagesWithScrollView(scrollView, animated: false)
        }
    }
    
    // MARK: - ViewController access by index
    
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
    
    // Status bar handling
    
    override public func childViewControllerForStatusBarHidden() -> UIViewController? {
        return currentViewController
    }
    override public func childViewControllerForStatusBarStyle() -> UIViewController? {
        return currentViewController
    }
}
