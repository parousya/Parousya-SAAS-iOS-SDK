#
# Be sure to run `pod lib lint ParousyaSAASSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ParousyaSAASSDK'
  s.version          = '0.1.0'
  s.summary          = 'iOS SDK for Parousya clients'
  s.homepage         = 'https://www.parousya.com'
  s.license          = 'MIT'
  s.author           = { 'Xuan Jie Chew' => 'xuanjie@buuuk.com' }
  
  s.platform     = :ios, '10.0'
  s.swift_version = '5.1'
  s.requires_arc = true
  
  s.source       = { :http => 'https://github.com/parousya/Parousya-SAAS-iOS-SDK/releases/download/0.1.0/ParousyaSAASSDK_0.1.0.zip' }
  s.ios.deployment_target = '10.0'
  s.ios.vendored_frameworks = 'ParousyaSAASSDK.framework'
  s.module_name = 'ParousyaSAASSDK'
  
  s.static_framework = true
	
  s.dependency 'SwiftKeychainWrapper'
  s.dependency 'EstimoteProximitySDK'
end
