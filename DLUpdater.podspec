#
# Be sure to run `pod lib lint DLUpdater.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DLUpdater'
  s.version          = '0.1.0'
  s.summary          = 'A framework for update notification of iOS application.'
  s.description      = <<-DESC
                        A framework for update notification of iOS application.
                       DESC

  s.homepage         = 'https://github.com/dklinzh/DLUpdater'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Lin' => 'linzhdk@gmail.com' }
  s.source           = { :git => 'https://github.com/Daniel Lin/DLUpdater.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'DLUpdater/Classes/**/*'
  s.dependency 'Siren', '~> 2.0'
end
