Pod::Spec.new do |s|
  s.name         = "WKTimerLabel" 
  s.version      = "1.0.5"        
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = "WKTimerLabel"

  s.homepage     = "https://github.com/GrapeFruitJun/WKTimerLabel"
  s.source       = { :git => "https://github.com/GrapeFruitJun/WKTimerLabel.git", :tag => "#{s.version}" }
  s.source_files = "WKTimerLabel/**/*" 
  s.swift_version = '5'
  s.platform     = :ios, "11.0" 
  s.frameworks   = "UIKit", "Foundation" 
  
  # User
  s.author       = { "Justin" => "wukai90s@gmail.com" } 

end