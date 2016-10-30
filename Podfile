# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!
inhibit_all_warnings!

target 'WWDCast' do
  pod 'google-cast-sdk', '~> 3.1.1'
  pod 'RxCocoa', '~> 2.6'
  pod 'RxOptional', '~> 2.0'
  pod 'RxDataSources', '~> 0.9'
  pod 'SwiftyJSON', '~> 2.3'
  pod 'SDWebImage', '~> 3.8'
  pod 'GRDB.swift', '~> 0.81.2'
end

target 'WWDCastTests' do

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
