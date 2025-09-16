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
  pod 'Swinject'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'PhoneNumberKit', :git => 'https://github.com/marmelroy/PhoneNumberKit'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Kingfisher'
  pod 'IKEventSource'
  pod 'ContactsChangeNotifier'
end

target 'Spika' do
  shared_pods
end

target 'Spika Dev' do
  shared_pods
end

target 'Spika Messenger' do
  shared_pods
end

target 'Share Extension' do
  shared_pods
end
