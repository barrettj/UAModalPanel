Pod::Spec.new do |s|
  s.name     = 'Barrett-UAModalPanel'
  s.version  = '1.2.0'
  s.license  = 'BSD'
  s.summary  = 'An animated modal panel alternative for iOS.'
  s.homepage = 'http://coneybeare.net'
  s.author   = { 'Matt Coneybeare' => 'coneybeare@gmail.com' }
  s.source   = { :git => 'https://github.com/barrettj/UAModalPanel.git', :tag => '1.2.0' }
  s.platform = :ios  
  s.source_files = 'UAModalPanel/UIView+JMNoise.{h,m}', 'UAModalPanel/UAGradientBackground.{h,m}', 'UAModalPanel/UAModalPanel.{h,m}', 'UAModalPanel/UANoisyGradientBackground.{h,m}', 'UAModalPanel/UARoundedRectView.{h,m}', 'UAModalPanel/UATitledModalPanel.{h,m}'
  s.resources = "UAModalPanel/*.png"
  s.framework = 'UIKit' , 'QuartzCore'
end