
Pod::Spec.new do |spec|


  spec.name         = "DBXKit"
  spec.version      = "0.1.0"
  spec.summary      = "A short description of DBXKit."

  spec.homepage     = "https://github.com/ImageView/"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "调包侠" => "526951107@qq.com" }

  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://git.woa.com/asherluo/DBXKit.git", :tag => spec.version }

  #spec.source_files  = "Classes", "DBXKit/Classes/**/*"
  #spec.exclude_files = "DBXKit/Classes/Exclude"

  spec.default_subspecs = 'Core','Extension'

  spec.subspec 'Core' do |ss|
       ss.source_files = 'DBXKit/Classes/Views/Core/**/*'
  end
  
  spec.subspec 'LabelsView' do |ss|
       ss.source_files = 'DBXKit/Classes/Views/LabelsView/**/*'
       #ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Extension' do |ss|
       ss.source_files = 'DBXKit/Classes/Extension/**/*'
       #ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'SmartReport' do |ss|
        ss.source_files = 'DBXKit/Classes/SmartReport/**/*'
        ss.dependency 'DBXKit/SmartReport'
  end
  
end
