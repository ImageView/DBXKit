
Pod::Spec.new do |spec|


  spec.name         = "DBXKit"
  spec.version      = "0.7.5"
  spec.summary      = "A short description of DBXKit."

  spec.homepage     = "https://github.com/ImageView/"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "DBX" => "526951107@qq.com" }

  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://git.woa.com/asherluo/DBXKit.git", :tag => spec.version }

  #spec.source_files  = "Classes", "DBXKit/Classes/**/*"
  #spec.exclude_files = "DBXKit/Classes/Exclude"

  #spec.default_subspecs = 'Core','Extension','LabelsView','Tools','Chain'

  spec.subspec 'Core' do |ss|
       ss.source_files = 'DBXKit/Classes/Core/**/*'
  end
  
  spec.subspec 'LabelsView' do |ss|
       ss.source_files = 'DBXKit/Classes/Views/LabelsView/**/*'
       #ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Extension' do |ss|
       ss.source_files = 'DBXKit/Classes/Extension/**/*'
       ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Syringe' do |ss|
        ss.source_files = 'DBXKit/Classes/Syringe/**/*'
        ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Tools' do |ss|
       ss.source_files = 'DBXKit/Classes/Tools/**/*'
       ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Chain' do |ss|
       ss.source_files = 'DBXKit/Classes/Chain/**/*'
       ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Debounce' do |ss|
       ss.source_files = 'DBXKit/Classes/Debounce/**/*'
       ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Track' do |ss|
       ss.source_files = 'DBXKit/Classes/Track/**/*'
       ss.dependency 'DBXKit/Core'
  end
  
  spec.subspec 'Stubs' do |ss|
       ss.source_files = 'DBXKit/Classes/Stubs/**/*'
       ss.dependency 'DBXKit/Core'
  end
end
