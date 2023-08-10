
Pod::Spec.new do |spec|


  spec.name         = "DBXKit"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of DBXKit."

  spec.homepage     = "https://github.com/ImageView/"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "调包侠" => "526951107@qq.com" }

  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/ImageView", :tag => spec.version }

  spec.source_files  = "Classes", "DBXKit/Classes/**/*.{h,m}"
  spec.exclude_files = "DBXKit/Classes/Exclude"

  # spec.public_header_files = "DBXKit/Classes/**/*.h"

  # spec.resource  = "icon.png"
  # spec.resources = "DBXKit/Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
