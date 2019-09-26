#
# Be sure to run `pod lib lint DLUpdater.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DLUpdater'
  s.version          = '0.5.0'
  s.summary          = 'An extension framework based on `Siren` for checking update of iOS app.'
  s.description      = <<-DESC
                        An extension framework based on `Siren` for checking update of iOS app.
                       DESC

  s.homepage         = 'https://github.com/dklinzh/DLUpdater'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Lin' => 'linzhdk@gmail.com' }
  s.source           = { :git => 'https://github.com/dklinzh/DLUpdater.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'

  s.source_files = 'DLUpdater/Classes/**/*'
  s.dependency 'Siren', '5.2.1'
end
