Pod::Spec.new do |s|
  s.name             = 'Leash'
  s.version          = '1.0.0'
  s.summary          = 'Network Abstraction Layer'
  s.description      = <<-DESC
                          Network Abstraction Layer in Swift.
                          Alamofire, Encodable, Decodable, Interceptors, Customization.
                          DESC
  s.homepage         = 'https://github.com/lucianopolit/Leash'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luciano Polit' => 'lucianopolit@gmail.com' }
  s.source           = { :git => 'https://github.com/lucianopolit/Leash.git', :tag => s.version.to_s }
  s.platform         = :ios, "8.0"
  s.source_files = 'Source/**/*.swift'
  s.dependency 'Alamofire', '~> 4.5'
end
