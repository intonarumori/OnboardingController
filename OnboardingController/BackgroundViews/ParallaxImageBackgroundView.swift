//
//  BackgroundContentView.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

/// ParallaxImageBackgroundView will scroll your image in the background based on the completion of the onboarding flow.
class ParallaxImageBackgroundView: UIView, OnboardingAnimatedBackgroundContentView {

    var imageView:UIImageView!
    var currentCompletionPercent:CGFloat = 0.0
    var shouldBlurImage:Bool = false
    
    /**
     Designated initializer for ParallaxImageBackgroundView
     
     - Parameter image The UIImage you want to scroll in the background
     */
    init(image:UIImage) {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.clipsToBounds = true
        
        self.imageView = UIImageView(image: image)
        self.imageView.backgroundColor = UIColor.blueColor()
        self.imageView.contentMode = .ScaleAspectFill
        self.addSubview(self.imageView)
        
        self.updateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - OnboardingAnimatedBackgroundContentView methods
    
    func setOnboardingCompletionPercent(percent: CGFloat) {
        self.currentCompletionPercent = percent
        self.updateLayout()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        self.updateLayout()
    }
    
    func updateLayout() {
        
        let size = self.bounds.size
        
        if (!CGSizeEqualToSize(size, CGSizeZero) && self.imageView.image != nil) {
            let imageSize = self.imageView.image!.size
            let scaleRatio = size.height / imageSize.height
            
            let scaledSize = CGSizeMake(imageSize.width * scaleRatio, imageSize.height * scaleRatio)
            
            let offsetX = -(scaledSize.width - size.width * 2.0) * currentCompletionPercent - size.width/2.0
            self.imageView.frame = CGRectMake(offsetX, 0, scaledSize.width, scaledSize.height)
        }
    }
}
