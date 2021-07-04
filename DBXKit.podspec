Pod::Spec.new do |s|
  s.name             = "DBXKit"
  s.version          = "0.0.1"
  s.summary          = "Commonly used components"
  s.homepage         = "https://github.com/ImageView/"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "diaobaoxia" => "526951107@qq.com" }
  s.source           = { :git => "http://git.code.oa.com/MNA-iOS/MnaKit.git", :tag => s.version,:branch => 'develop'}
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.static_framework = true  
  s.source_files  = /Classes/**/*"
  
  
  s.module_name = 'DBXKit'
  
end
