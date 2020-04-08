Pod::Spec.new do |s|
  s.name             = 'Leash'
  s.version          = '3.1.1'
  s.summary          = 'Network Abstraction Layer'
  s.description      = <<-DESC
                          Network Abstraction Layer in Swift.
                          Alamofire, Encodable, Decodable, Interceptors, Customization, RxSwift.
                          DESC
  s.homepage         = 'https://github.com/lucianopolit/Leash'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luciano Polit' => 'lucianopolit@gmail.com' }
  s.source           = { :git => 'https://github.com/lucianopolit/Leash.git', :tag => s.version.to_s }
  s.platform         = :ios, '10.0'
  s.swift_version    = '5.0'
  s.default_subspec  = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files  = 'Source/Core/**/*.swift'
    ss.dependency      'Alamofire', '~> 5.0'
  end

  s.subspec 'RxSwift' do |ss|
    ss.source_files  = 'Source/RxSwift/*.swift'
    ss.dependency      'RxSwift', '~> 5.0'
    ss.dependency      'Leash/Core'
  end

  s.subspec 'Interceptors' do |ss|
    ss.source_files  = 'Source/Interceptors/*.swift'
    ss.dependency      'Leash/Core'
  end

end
