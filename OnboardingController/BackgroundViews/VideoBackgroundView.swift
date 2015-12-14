//
//  VideoBackgroundView.swift
//  OnboardingViewController
//
//  Created by Daniel Langh on 12/12/15.
//  Copyright © 2015 rumori. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoBackgroundView: UIView {

    var videoURL:NSURL!
    var moviePlayerController:MPMoviePlayerController!
    
    deinit {
        self.stopPlaying()
        self.moviePlayerController = nil
    }
    
    init(videoURL:NSURL) {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = UIColor.blackColor()
        self.videoURL = videoURL

        self.moviePlayerController = MPMoviePlayerController()
        self.moviePlayerController.contentURL = self.videoURL
        self.moviePlayerController.repeatMode = MPMovieRepeatMode.One
        self.moviePlayerController.controlStyle = MPMovieControlStyle.None
        self.addSubview(self.moviePlayerController.view)
        
        self.startPlaying()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startListeningToApplicationNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("handleAppEnteredForeground"),
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
    }
    
    func stopListeningToApplicationNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
    }
    
    func startPlaying() {
        self.moviePlayerController.play()
    }
    
    func stopPlaying() {
        if self.moviePlayerController.playbackState == .Playing {
            self.moviePlayerController.stop()
        }
    }
    
    // MARK: -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.moviePlayerController.view.frame = self.bounds
    }
}
