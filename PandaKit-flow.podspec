#
# Be sure to run `pod lib lint PandaKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PandaKit-flow'
  s.version          = '0.1.1'
  s.summary          = 'An asynchronous render and layout framework which can be used to achieve high performance tableview'

  s.description      = <<-DESC
Panda is a asynchronous render and layout framework which can be used to achieve high performance tableview.
                       DESC

  s.homepage         = 'https://github.com/nangege/Panda'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ljk' => 'liujk0723@gmail.com' }
  s.source           = { :git => 'https://github.com/NeverAgain11/PandaKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'PandaKit/Classes/**/*'
  
  s.swift_version = "5.0"

  s.module_name = "Panda"
  
end
