//
//  ViewController.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

public class BoxViewController: UIViewController, OnboardingContentViewController {

    @IBOutlet var imageView:UIImageView?
    @IBOutlet var titleLabel:UILabel?
    @IBOutlet var bodyLabel:UILabel?
    @IBOutlet var button:UIButton?
    @IBOutlet var imageViewHorizontalCenterConstraint:NSLayoutConstraint?
    
    var image:UIImage?
    var titleText:String?
    var bodyText:String?
    var buttonText:String? = "Next"
    var buttonHandler: ((BoxViewController) -> Void)?
    
    var currentVisibilityPercent:CGFloat = 0.0
    
    init(titleText:String?, bodyText:String? = nil, image:UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.titleText = titleText
        self.bodyText = bodyText
        self.image = image
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(titleText:nil)
    }
    
    // MARK: -
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // clip content so no overlapping will occur between onboarding content
        self.view.clipsToBounds = true
        
        // set background to transparent so we can see the background view of OnboardingController
        self.view.backgroundColor = UIColor.clearColor()

        self.imageView?.image = self.image
        self.titleLabel?.text = self.titleText
        self.bodyLabel?.text = self.bodyText
        
        self.button?.setTitle(self.buttonText, forState: .Normal)

        self.button?.layer.borderColor = UIColor.blackColor().CGColor
        self.button?.layer.borderWidth = 1.0
        self.button?.layer.cornerRadius = 5.0
    }
    
    // MARK: - OnboardingAnimatedContentViewController
    
    func setVisibilityPercent(percent: CGFloat) {
        self.currentVisibilityPercent = percent
        self.updateImageViewHorizontalCenterConstraint()
    }
    
    override public func updateViewConstraints() {
        super.updateViewConstraints()
        self.updateImageViewHorizontalCenterConstraint()
    }

    func updateImageViewHorizontalCenterConstraint() {
        
        if let image = self.imageView!.image {
            let width = self.view.bounds.size.width
            let availableWidth = width - image.size.width
            self.imageViewHorizontalCenterConstraint?.constant = availableWidth / 2.0 * (currentVisibilityPercent-1.0)
        }
    }
    
    // MARK: - user actions
    
    @IBAction func buttonPressed() {
        if let handler = self.buttonHandler {
            handler(self)
        } else {
            self.moveToNext()
        }
    }
    
    func moveToNext() {
        self.onboardingController()?.moveToNext(true)
    }
    
    func moveToPrevious() {
        self.onboardingController()?.moveToPrevious(true)
    }
}

