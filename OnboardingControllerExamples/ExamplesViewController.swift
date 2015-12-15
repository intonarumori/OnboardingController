//
//  ExamplesViewController.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit

class ExampleItem {
    var title:String = ""
    var action:Void->Void
    
    init(title:String, action:Void->Void) {
        self.title = title
        self.action = action
    }
}

class ExamplesViewController: UITableViewController {

    var items:Array<ExampleItem>?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        self.title = "Onboarding examples"

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.items = [
            ExampleItem(title: "Parallax with progress fading", action: { () -> Void in
                
                let progressView = PagingProgressView()
                progressView.skipButton.addTarget(self, action: Selector("closeOnboarding"), forControlEvents: .TouchUpInside)
                
                let onboardingController = OnboardingController(
                    viewControllers: [
                        WelcomeViewController(),
                        LocationSharingViewController(),
                        BackgroundDescriptionViewController(),
                        PagingProgressViewDescriptionViewController()
                    ],
                    backgroundContentView: ParallaxImageBackgroundView(image: UIImage(named:"white-wood.jpg")!),
                    progressView: progressView
                )
                self.presentViewController(onboardingController, animated: true, completion: nil)
                
            })
            /*
            ,
            ExampleItem(title: "Parallax without fading", action: { () -> Void in
                
                let progressView = PagingProgressView()
                progressView.fadeSkipButtonOnLastPage = false
                progressView.fadePageControlOnLastPage = false
                progressView.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
                progressView.pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
                progressView.skipButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                progressView.skipButton.addTarget(self, action: Selector("closeOnboarding"), forControlEvents: .TouchUpInside)
                
                let firstViewController = BoxViewController(titleText: "Oberheim DX", bodyText: "For the west coast funk flavor", image: UIImage(named: "obi-dx.png"))
                let secondViewcontroller = BoxViewController(titleText: "Roland TR-909", bodyText: "Rocking house dancefloors since the 80s", image: UIImage(named: "tr-909.png"))
                let thirdViewController = BoxViewController(titleText: "Roland TR-808", bodyText: "For the ultimate earth shaking kick drum", image: UIImage(named: "tr-808.png"))
                thirdViewController.buttonText = "Go!"
                thirdViewController.buttonHandler = {
                    (arg:BoxViewController) -> Void in
                    self.closeOnboarding()
                }
                
                let onboardingController = OnboardingController(
                    viewControllers: [firstViewController, secondViewcontroller, thirdViewController],
                    backgroundContentView: ParallaxImageBackgroundView(image: UIImage(named:"white-wood.jpg")!),
                    progressView: progressView
                )
                self.presentViewController(onboardingController, animated: true, completion: nil)
                
            }),
            ExampleItem(title: "Parallax without skip", action: { () -> Void in
                
                let progressView = PagingProgressView()
                progressView.fadeSkipButtonOnLastPage = true
                progressView.fadePageControlOnLastPage = true
                progressView.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
                progressView.pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
                progressView.skipEnabled = false
                
                let firstViewController = BoxViewController(titleText: "Oberheim DX", bodyText: "For the west coast funk flavor", image: UIImage(named: "obi-dx.png"))
                let secondViewcontroller = BoxViewController(titleText: "Roland TR-909", bodyText: "Rocking house dancefloors since the 80s", image: UIImage(named: "tr-909.png"))
                let thirdViewController = BoxViewController(titleText: "Roland TR-808", bodyText: "For the ultimate earth shaking kick drum", image: UIImage(named: "tr-808.png"))
                thirdViewController.buttonText = "Go!"
                thirdViewController.buttonHandler = {
                    (arg:BoxViewController) -> Void in
                    self.closeOnboarding()
                }
                
                let onboardingController = OnboardingController(
                    viewControllers: [firstViewController, secondViewcontroller, thirdViewController],
                    backgroundContentView: ParallaxImageBackgroundView(image: UIImage(named:"white-wood.jpg")!),
                    progressView: progressView
                )
                self.presentViewController(onboardingController, animated: true, completion: nil)
                
            }),
            ExampleItem(title: "Parallax without progress", action: { () -> Void in
                
                let firstViewController = BoxViewController(titleText: "Oberheim DX", bodyText: "For the west coast funk flavor", image: UIImage(named: "obi-dx.png"))
                let secondViewcontroller = BoxViewController(titleText: "Roland TR-909", bodyText: "Rocking house dancefloors since the 80s", image: UIImage(named: "tr-909.png"))
                let thirdViewController = BoxViewController(titleText: "Roland TR-808", bodyText: "For the ultimate earth shaking kick drum", image: UIImage(named: "tr-808.png"))
                thirdViewController.buttonText = "Go!"
                thirdViewController.buttonHandler = {
                    (arg:BoxViewController) -> Void in
                    self.closeOnboarding()
                }
                
                let onboardingController = OnboardingController(
                    viewControllers: [firstViewController, secondViewcontroller, thirdViewController],
                    backgroundContentView: ParallaxImageBackgroundView(image: UIImage(named:"white-wood.jpg")!),
                    progressView: nil
                )
                self.presentViewController(onboardingController, animated: true, completion: nil)
                
            }),
            ExampleItem(title: "Video", action: { () -> Void in
                
                let videoURL = NSBundle.mainBundle().URLForResource("sun", withExtension: "mp4")!
                let progressView = PagingProgressView()
                progressView.skipButton.addTarget(self, action: Selector("closeOnboarding"), forControlEvents: .TouchUpInside)
                let onboardingController = OnboardingController(
                    viewControllers: [
                        BoxViewController(titleText: "First page", bodyText: "First page body", image: nil),
                        BoxViewController(titleText: "Second page", bodyText: "Second page body", image: nil),
                        BoxViewController(titleText: "Third page", bodyText: "Third page body", image: nil)
                    ],
                    backgroundContentView: VideoBackgroundView(videoURL: videoURL),
                    progressView: progressView
                )
                self.presentViewController(onboardingController, animated: true, completion: nil)
            }),
*/
        ]
    }

    // MARK: - user actions
    
    func closeOnboarding() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - tableview delegate/datasource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.items == nil ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items != nil ? self.items!.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = self.items![indexPath.row].title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let items = self.items {
            let item = items[indexPath.row]
            item.action()
        }
    }
}