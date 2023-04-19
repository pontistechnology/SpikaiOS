# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end


# Pods for Spika
def shared_pods
  pod 'GoogleDataTransport', '~> 9.2'
  pod 'Swinject', '~> 2.8'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'PhoneNumberKit', :git => 'https://github.com/marmelroy/PhoneNumberKit'
  pod 'Firebase/Core', '~> 10.8'
  pod 'Kingfisher', '~> 7.6'
  pod 'Firebase/Analytics', '~> 10.8'
  pod 'Firebase/Crashlytics', '~> 10.8'
  pod 'Firebase/Messaging', '~> 10.8'
  pod 'IKEventSource', '~> 2.2'
end

target 'Spika' do
  shared_pods
end

target 'Spika Dev' do
  shared_pods
end
