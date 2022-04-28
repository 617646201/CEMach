#
# Be sure to run `pod lib lint CEMach.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CEMach'
  s.version          = '0.1.0'
  s.summary          = 'Mach 安全校验'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zhiyong/CEMach'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhiyong' => '617646201@qq.com' }
  s.source           = { :git => 'https://github.com/zhiyong/CEMach.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.source_files = 'CEMach/Classes/**/*'
  s.public_header_files = 'CEMach/Classes/**/CEMach.h'
  
  # s.resource_bundles = {
  #   'CEMach' => ['CEMach/Assets/*.png']
  # }

   
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
