# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

inhibit_all_warnings!
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

# Bugfix: App Icons not included in build from Xcode 9
# https://github.com/CocoaPods/CocoaPods/issues/7003
    copy_pods_resources_path = "Pods/Target Support Files/Pods-WWDCast/Pods-WWDCast-resources.sh"
    string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
    assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
    text = File.read(copy_pods_resources_path)
    new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
    File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }

end
