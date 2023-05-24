# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

use_frameworks!

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end

# Pods for Spika
def shared_pods
  pod 'Swinject', '2.8.3'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'PhoneNumberKit', :git => 'https://github.com/marmelroy/PhoneNumberKit'
  pod 'Firebase/Analytics', '10.8.0'
  pod 'Firebase/Crashlytics', '10.8.0'
  pod 'Firebase/Messaging', '10.8.0'
  pod 'Kingfisher', '7.6.2'
  pod 'IKEventSource', '3.0.1'
  pod 'ContactsChangeNotifier'
end

target 'Spika' do
  shared_pods
end

target 'Spika Dev' do
  shared_pods
end
