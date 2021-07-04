
Pod::Spec.new do |spec|


  spec.name         = "DBXKit"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of DBXKit."
  spec.description  = <<-DESC
                   DESC

  spec.homepage     = "https://github.com/ImageView/DBXKit.git"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "调包侠" => "526951107@qq.com" }

  spec.platform     = :ios, "9.0"
  source       = { :git => "https://github.com/ImageView/DBXKit.git", :tag => "#{spec.version}" }

  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
