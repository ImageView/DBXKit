source 'https://github.com/CocoaPods/Specs.git'
workspace 'DBXKit.xcworkspace'
project 'DBXKit.xcodeproj'
# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'
inhibit_all_warnings!
#abstract_target 'abstract_pod' do
 #use_frameworks!


target 'DBXKit' do
 use_frameworks!
 inherit! :search_paths
      pod 'Masonry'
      
      pod 'SDWebImage'
      pod 'MJRefresh'
      pod 'IQKeyboardManager'
      pod 'QMUIKit'
     
  # Pods for MnaVpncd

end


#解决'sharedApplication' is unavailable: not available on iOS (App Extension)
post_install do |installer_representation|

installer_representation.pods_project.targets.each do |target|

target.build_configurations.each do |config|

config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'

end

end

end

#end
