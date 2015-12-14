Pod::Spec.new do |s|
  s.name = "OnboardingController"
  s.version = "0.0.1"
  s.summary = "A flexible library for creating and customizing onboarding flows written in Swift"
  s.homepage = "https://github.com/intonarumori/OnboardingController"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.authors = "Daniel Langh"
  s.ios.deployment_target = "8.0"
  s.source = { :git => "https://github.com/intonarumori/OnboardingController.git", :tag => '0.0.1' }
  s.source_files = 'OnboardingController/*.swift', 'OnboardingController/ProgressViews/*.swift', 'OnboardingController/ContentViewControllers/*.swift', 'OnboardingController/BackgroundViews/*.swift'
end