//
//  OnboardingProgressView.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

open class PagingProgressView: UIView, OnboardingProgressViewProtocol {

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
            self.skipButton.isHidden = !skipEnabled
        }
    }
    
    public convenience init() {
        self.init(frame:CGRect(x: 0, y: 0, width: 100, height: 50))
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear

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
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageControl.addTarget(self, action: #selector(pageValueChanged), for: .valueChanged)
        self.addSubview(pageControl)
        
        
        self.pageControl = pageControl
    }
    
    @objc func pageValueChanged(_ pageControl:UIPageControl) {
        if currentPage < pageControl.currentPage {
            self.onboardingController?.moveToNext(true)
        }
        else if currentPage > pageControl.currentPage {
            self.onboardingController?.moveToPrevious(true)
        }
    }
    
    func createSkipButton() {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        self.addConstraints([
            NSLayoutConstraint(
                item: button, attribute: .trailing,
                relatedBy: .equal,
                toItem: self, attribute: .trailing,
                multiplier: 1.0, constant: -15),
            NSLayoutConstraint(
                item: button, attribute: .bottom,
                relatedBy: .equal,
                toItem: self, attribute: .bottom,
                multiplier: 1.0, constant: -10)
            ])
        
        self.skipButton = button
    }
    
    // MARK: -
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.pageControl.frame = self.bounds
    }
    
    // MARK: -
    
    open func setNumberOfViewControllersInOnboarding(_ numberOfViewControllers: Int) {
        self.numberOfPages = numberOfViewControllers
        self.pageControl.numberOfPages = self.numberOfPages
    }
    
    open func setOnboardingCompletionPercent(_ percent: CGFloat) {
        
        let index = self.pageIndexForCompletionPercent(percent)
        
        if(self.currentPage != index) {
            self.currentPage = index
            self.pageControl.currentPage = self.currentPage
            
            self.updateFading()
            self.updateSkipFading()
        }
    }
    
    fileprivate func updateFading() {
        if fadePageControlOnLastPage {
            if self.currentPage == (self.numberOfPages - 1) {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.pageControl.alpha = 0.0
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.pageControl.alpha = 1.0
                })
            }
        } else {
            self.pageControl.alpha = 1.0
        }
    }
    
    fileprivate func updateSkipFading() {
        if fadeSkipButtonOnLastPage {
            if self.currentPage == (self.numberOfPages - 1) {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.skipButton.alpha = 0.0
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.skipButton.alpha = 1.0
                })
            }
        } else {
            self.skipButton.alpha = 1.0
        }
    }
    
    fileprivate func pageIndexForCompletionPercent(_ percent:CGFloat) -> Int {
        let rangeForPage = 1.0 / CGFloat(numberOfPages - 1)
        let index = Int(round( (percent) / rangeForPage ))
        return index
    }
}
