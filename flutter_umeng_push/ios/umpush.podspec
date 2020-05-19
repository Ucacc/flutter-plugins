#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint umpush.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'umpush'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter Plugin For UMeng Push.'
  s.description      = <<-DESC
A Flutter Plugin For UMeng Push.
                       DESC
  s.homepage         = 'https://github.com/ucacc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ucacc' => 'TsingMingCheung@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'UMCCommon'
  s.dependency 'UMCCommonLog'
  s.dependency 'UMCSecurityPlugins'
  s.dependency 'UMCPush'
#  s.dependency 'UMCCommon', '~>2.1.4' # 开发此插件时, 使用的版本
#  s.dependency 'UMCCommonLog', '~>1.0.0' # 开发此插件时, 使用的版本
#  s.dependency 'UMCSecurityPlugins', '~>1.0.6' # 开发此插件时, 使用的版本
#  s.dependency 'UMCPush', '~>3.2.4' # 开发此插件时, 使用的版本
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
