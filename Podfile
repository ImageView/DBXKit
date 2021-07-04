source 'https://github.com/CocoaPods/Specs.git'
workspace 'DBXKit.xcworkspace'
project 'DBXKit.xcodeproj'
platform :ios, '9.0'
inhibit_all_warnings!

target 'DBXKit' do
 use_frameworks!
 inherit! :search_paths
      pod 'Masonry'
      
      pod 'SDWebImage'
      pod 'MJRefresh'
      pod 'IQKeyboardManager'
      pod 'QMUIKit'

end


post_install do |installer_representation|

installer_representation.pods_project.targets.each do |target|

target.build_configurations.each do |config|

config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'

end

end

end

