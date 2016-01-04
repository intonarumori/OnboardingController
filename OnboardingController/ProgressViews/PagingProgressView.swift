//
//  OnboardingProgressView.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

public class PagingProgressView: UIView, OnboardingProgressView {

    var pageControl:UIPageControl!
    var skipButton:UIButton!
    
    var numberOfPages:Int = 0
    var currentPage:Int = 0
    
    var fadeSkipButtonOnLastPage:Bool = false {
        didSet {
            self.updateSkipFading()
        }
    }
    var fadePageControlOnLastPage:Bool = false {
        didSet {
            self.updateFading()
        }
    }
    var skipEnabled:Bool = true {
        didSet {
            self.skipButton.hidden = !skipEnabled
        }
    }
    
    public convenience init() {
        self.init(frame:CGRectMake(0, 0, 100, 50))
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()

        self.createPageControl()
        self.createSkipButton()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    func createPageControl() {
        let pageControl = UIPageControl()
        pageControl.frame = self.bounds
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.userInteractionEnabled = false
        pageControl.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(pageControl)
        self.pageControl = pageControl
    }
    
    func createSkipButton() {
        let button = UIButton()
        button.setTitle("Skip", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        self.addConstraints([
            NSLayoutConstraint(
                item: button, attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self, attribute: .Trailing,
                multiplier: 1.0, constant: -15),
            NSLayoutConstraint(
                item: button, attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self, attribute: .Bottom,
                multiplier: 1.0, constant: -10)
            ])
        
        self.skipButton = button
    }
    
    // MARK: -
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.pageControl.frame = self.bounds
    }
    
    // MARK: -
    
    public func setNumberOfViewControllersInOnboarding(numberOfViewControllers: Int) {
        self.numberOfPages = numberOfViewControllers
        self.pageControl.numberOfPages = self.numberOfPages
    }
    
    public func setOnboardingCompletionPercent(percent: CGFloat) {
        
        let index = self.pageIndexForCompletionPercent(percent)
        
        if(self.currentPage != index) {
            self.currentPage = index
            self.pageControl.currentPage = self.currentPage
            
            self.updateFading()
            self.updateSkipFading()
        }
    }
    
    private func updateFading() {
        if fadePageControlOnLastPage {
            if self.currentPage == (self.numberOfPages - 1) {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.pageControl.alpha = 0.0
                })
            } else {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.pageControl.alpha = 1.0
                })
            }
        } else {
            self.pageControl.alpha = 1.0
        }
    }
    
    private func updateSkipFading() {
        if fadeSkipButtonOnLastPage {
            if self.currentPage == (self.numberOfPages - 1) {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.skipButton.alpha = 0.0
                })
            } else {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.skipButton.alpha = 1.0
                })
            }
        } else {
            self.skipButton.alpha = 1.0
        }
    }
    
    private func pageIndexForCompletionPercent(percent:CGFloat) -> Int {
        let rangeForPage = 1.0 / CGFloat(numberOfPages - 1)
        let index = Int(round( (percent) / rangeForPage ))
        return index
    }
}
