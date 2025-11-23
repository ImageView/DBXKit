source 'https://github.com/CocoaPods/Specs.git'
source 'https://git.woa.com/MNA-iOS/MnaSpec.git' #Mna私有库地址

workspace 'DBXKit.xcworkspace'
project 'DBXKit.xcodeproj'
platform :ios, '11.0'
inhibit_all_warnings!

target 'DBXKit' do
 use_frameworks!
 inherit! :search_paths
      pod 'Masonry'
      
      pod 'SDWebImage'
      pod 'MJRefresh'
      pod 'IQKeyboardManager'
      pod 'QMUIKit'
#      pod 'MnaDebuggingOnLine'

end


post_install do |installer_representation|

installer_representation.pods_project.targets.each do |target|

target.build_configurations.each do |config|

config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
end

end

end

