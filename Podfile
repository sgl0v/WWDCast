# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'WWDCast' do
  pod 'google-cast-sdk', '~> 3.1.1'
  pod 'RxCocoa', '~> 3.6.1'
  pod 'RxDataSources', '~> 2.0.2'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'SDWebImage', '~> 3.8'

    target 'WWDCastTests' do
        inherit! :search_paths
    end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
            config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
        end
    end

    work_dir = Dir.pwd
    Dir.glob("Pods/Target Support Files/Pods-WWDCast/*.xcconfig") do |xc_config_filename|
        full_path_name = "#{work_dir}/#{xc_config_filename}"
        xc_config = File.read(full_path_name)
        new_xc_config = xc_config.sub(/FRAMEWORK_SEARCH_PATHS/, 'PODS_FRAMEWORK_SEARCH_PATHS')
        new_xc_config = new_xc_config.sub(/HEADER_SEARCH_PATHS/, 'PODS_HEADER_SEARCH_PATHS')
        new_xc_config = new_xc_config.sub(/LIBRARY_SEARCH_PATHS/, 'PODS_LIBRARY_SEARCH_PATHS')
        new_xc_config = new_xc_config.sub(/OTHER_LDFLAGS/, 'PODS_OTHER_LDFLAGS')
        new_xc_config = new_xc_config.sub(/OTHER_CFLAGS/, 'PODS_OTHER_CFLAGS')
        new_xc_config = new_xc_config.sub(/GCC_PREPROCESSOR_DEFINITIONS/, 'PODS_GCC_PREPROCESSOR_DEFINITIONS')
        new_xc_config = new_xc_config.sub(/OTHER_SWIFT_FLAGS/, 'PODS_OTHER_SWIFT_FLAGS')
        File.open(full_path_name, 'w') { |file| file << new_xc_config }
    end

end

