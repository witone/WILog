#
# Be sure to run `pod lib lint WILog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WILog'
  s.version          = '0.2.1'
  s.summary          = '基于CocoaLumberjack的日志记录控件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 基于CocoaLumberjack的日志记录控件.
                       DESC

  s.homepage         = 'https://github.com/wikit-zyp/WILog'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zyp' => 'me_zyp@163.com' }
  s.source           = { :git => 'https://github.com/wikit-zyp/WILog.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WILog/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WILog' => ['WILog/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CocoaLumberjack'
end
