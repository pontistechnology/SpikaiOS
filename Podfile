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
  pod 'Swinject'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'PhoneNumberKit', :git => 'https://github.com/marmelroy/PhoneNumberKit'
  pod 'Kingfisher', '~> 7.6'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'IKEventSource'
end

target 'Spika' do
  shared_pods
end

target 'Spika Dev' do
  shared_pods
end
