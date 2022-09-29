#  Be sure to run `pod spec lint YKNetWorking.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.

Pod::Spec.new do |spec|
  spec.name         = "YKNetWorking"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of YKNetWorking."
  spec.homepage     = "https://gitee.com/Edwrard/YKNetWorking.git"
  spec.license      = "MIT"
  spec.author       = { "edward" => "534272374@qq.com" }
  spec.ios.deployment_target = "9.0"
  spec.source       = { :git => "https://gitee.com/Edwrard/YKNetWorking.git",:tag => spec.version.to_s }
  spec.framework  = "UIKit","Foundation","AVFoundation","Photos","Security"
  
  
  spec.default_subspec = 'BaseModule'
  
  
  #spec.prefix_header_file = "YKNetWorking.pch"
  
    spec.subspec "BaseModule" do |ss|
#        ss.source_files = 'YKUMSDK/Classes/BaseModule/*'
        ss.source_files = 'YKNetWorking/Classes/Base/*.{h,m,xib}'
        ss.dependency "AFNetworking"

    end
  
    spec.subspec 'RACExtension' do |ss|
      ss.source_files = 'YKNetWorking/Classes/RACExtension/*.{h,m,xib}'
      
      ss.dependency "ReactiveObjC"
    end
  
end

#  pod lib lint YKNetWorking.podspec --allow-warnings --verbose
#  push  tag
#  pod repo push YKSpec YKNetWorking.podspec --allow-warnings
