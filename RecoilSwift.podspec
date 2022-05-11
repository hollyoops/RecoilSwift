Pod::Spec.new do |s|
  s.name             = 'RecoilSwift'
  s.version          = '0.2.1'
  s.summary          = 'RecoilSwift is a next generation state management library'

  s.description      = <<-DESC
  RecoilSwift is a lightweight & reactive swift state management library. It's an alternate option to replace of the `Redux(reswift/tca)` or `MVVM`
                       DESC

  s.homepage         = 'https://github.com/hollyoops/RecoilSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hcli@thoughtworks.com' => 'hcli@thoughtworks.com' }
  s.source           = { :git => 'https://github.com/hollyoops/RecoilSwift.git', :tag => s.version.to_s }

  s.platform = :ios, '13.0'

  s.source_files = 'Sources/**/*.swift'
  s.exclude_files = 'Sources/**/*Tests.swift'
  s.swift_version = '5'
  s.dependency 'Hooks', '~> 0.0.3'
  
end
