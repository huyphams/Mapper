Pod::Spec.new do |s|

  s.name         = "Mapper"
  s.version      = "0.0.1"
  s.summary      = "Mapper can integrate with Swift probject (as example), map JSON to objects and map objects to JSON without manual implementation. It's very simple and easy to use."
  s.homepage     = "http://huypham.me"
  s.license      = "MIT"
  s.author             = { "Huy Pham" => "duchuykun@gmail.com" }
  s.social_media_url   = "https://www.instagram.com/huyphams"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/huyphams/Mapper.git", :tag => "#{s.version}" }
  s.source_files  = "Mapper/Classes/*.{h,m}"
  s.requires_arc = true

end
