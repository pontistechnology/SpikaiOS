# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

use_frameworks!

# Pods for Spika
def shared_pods
  pod 'Swinject', '~> 2.8'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'PhoneNumberKit', :git => 'https://github.com/marmelroy/PhoneNumberKit'
  pod 'Kingfisher', '~> 7.6'
  pod 'Firebase/Analytics', '~> 10.7'
  pod 'Firebase/Crashlytics', '~> 10.7'
  pod 'Firebase/Messaging', '~> 10.7'
  pod 'IKEventSource'
end

target 'Spika' do
  shared_pods
end

target 'Spika Dev' do
  shared_pods
end
