Pod::Spec.new do |s|

  s.name         = "HPMapper"
  s.version      = "1.0.1"
  s.summary      = "Mapper can integrate with Swift probject, map JSON to objects and map objects to JSON without manual implementation."
  s.homepage     = "http://huypham.me"
  s.license      = "MIT"
  s.author             = { "Huy Pham" => "duchuykun@gmail.com" }
  s.social_media_url   = "https://www.instagram.com/huyphams"
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.11'
  s.source       = { :git => "https://github.com/huyphams/Mapper.git", :tag => "#{s.version}" }
  s.source_files  = "Mapper/Classes/*.{h,m}"
  s.requires_arc = true

end
