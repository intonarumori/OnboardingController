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

    var videoURL: URL!
    var moviePlayerController: MPMoviePlayerController!

    deinit {
        self.stopPlaying()
        self.moviePlayerController = nil
    }

    init(videoURL: URL) {
        super.init(frame: .zero)

        self.backgroundColor = UIColor.black
        self.videoURL = videoURL

        self.moviePlayerController = MPMoviePlayerController()
        self.moviePlayerController.contentURL = self.videoURL
        self.moviePlayerController.repeatMode = MPMovieRepeatMode.one
        self.moviePlayerController.controlStyle = MPMovieControlStyle.none
        self.addSubview(self.moviePlayerController.view)

        self.startPlaying()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startListeningToApplicationNotifications() {
        /*
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleAppEnteredForeground),
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
         */
    }

    func stopListeningToApplicationNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    func startPlaying() {
        self.moviePlayerController.play()
    }

    func stopPlaying() {
        if self.moviePlayerController.playbackState == .playing {
            self.moviePlayerController.stop()
        }
    }

    // MARK: -

    override func layoutSubviews() {
        super.layoutSubviews()
        self.moviePlayerController.view.frame = self.bounds
    }
}
