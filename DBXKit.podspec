
Pod::Spec.new do |spec|


  spec.name         = "DBXKit"
  spec.version      = "0.0.6"
  spec.summary      = "A short description of DBXKit."

  spec.homepage     = "https://github.com/ImageView/"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "调包侠" => "526951107@qq.com" }

  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://git.woa.com/asherluo/DBXKit.git", :tag => spec.version }

  #spec.source_files  = "Classes", "DBXKit/Classes/**/*"
  #spec.exclude_files = "DBXKit/Classes/Exclude"

  spec.subspec 'LabelsView' do |labels|
       labels.source_files = 'DBXKit/Classes/Views/LabelsView/**/*'
  end
  spec.subspec 'Extension' do |ext|
         ext.source_files = 'DBXKit/Classes/Extension/**/*'
  end
end
