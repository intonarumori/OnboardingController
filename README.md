# OnboardingController

[![Build Status](https://travis-ci.org/intonarumori/OnboardingController.svg)](https://travis-ci.org/intonarumori/OnboardingController)

OnboardingController is a Swift 2.0 component for iOS applications to help you create the onboarding flow of your awesome app.


### It's flexible:
- display a list of regular viewcontrollers and OnboardingController handles the swiping and paging for you
    - additionally you can conform to `OnboardingControllerContentViewController` protocol to get notified about scrolling offset which is particularly useful for creating motion effects
- display any regular UIView in the background
    - OnboardingController will display your UIView as a fullscreen background
    - additionally you can conform to `OnboardingControllerBackgroundView` protocol to get notified about the scrolling offset of the entire onboarding flow. This is useful for creating motion effects
- display any regular UIView on the bottom of the screen
    - this is useful to display progress information
    - additionally you can conform to `OnboardingControllerProgressView` protocol to get notified about the scrolling offset of the entire onboarding flow. This is useful to create any progress display you want from UIPageControl to more complicated ones

OnboardingController was inspired by https://github.com/mamaral/Onboard

