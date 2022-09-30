#
# Be sure to run `pod lib lint YKNetWorking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YKNetWorking'
  s.version          = '1.0.0'
  s.summary          = 'A short description of YKNetWorking.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitee.com/Edwrard/YKNetWorking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'edwardyyk' => '534272374@qq.com' }
  s.source           = { :git => 'https://gitee.com/Edwrard/YKNetWorking.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  
  s.default_subspec = 'BaseModule'
  
  s.subspec "BaseModule" do |ss|
      ss.source_files = 'YKNetWorking/Classes/Base/*.{h,m,xib}'
      ss.dependency "AFNetworking"
  end

  s.subspec 'RACExtension' do |ss|
    ss.source_files = 'YKNetWorking/Classes/RACExtension/*.{h,m,xib}'
    
    ss.dependency "ReactiveObjC"
  end
  
end
