Pod::Spec.new do |s|
  s.name             = 'RecoilSwift'
  s.version          = '0.2.0'
  s.summary          = 'RecoilSwift is a next generation state management library'

  s.description      = <<-DESC
  Recoil is a next generation state management library power by facebook. RecoilSwift is a implementation of recoil for swift and swiftUI. We are making it UIKit compatible
                       DESC

  s.homepage         = 'https://github.com/hollyoops/RecoilSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hcli@thoughtworks.com' => 'hcli@thoughtworks.com' }
  s.source           = { :git => 'https://github.com/hollyoops/RecoilSwift.git', :tag => s.version.to_s }

  s.platform = :ios, '13.0'

  s.source_files = 'Sources/**/*.swift'
  s.exclude_files = 'Sources/**/*Tests.swift'
  s.swift_version = '5'
  
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*Tests.Swift', 'Sources/**/*Tests.swift'
  end
end
