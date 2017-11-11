Pod::Spec.new do |s|
  s.name             = 'Leash'
  s.version          = '0.0.1'
  s.summary          = 'Networking Abstraction Layer'
  s.description      = <<-DESC
                          Networking Abstraction Layer in Swift. Alamofire, Codable or Unbox and Wrap, Interceptors, Customizable.
                          DESC
  s.homepage         = 'https://github.com/lucianopolit/Leash'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luciano Polit' => 'lucianopolit@gmail.com' }
  s.source           = { :git => 'https://github.com/lucianopolit/Leash.git', :tag => s.version.to_s }
  s.platform         = :ios, "9.0"
  s.source_files = 'Source/**/*.swift'
  s.dependency 'Alamofire', '~> 4.5'
end
