Pod::Spec.new do |s|
  s.name     = 'WeatherController'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.platform = :ios, '5.0'
  s.summary  = ''
  s.homepage = ''
  s.author   = { '' => '' }
  s.source   = { :git => 'https://github.com/greenappleball/weather_controller.git', :tag => '0.0.1' }
  s.description = ''

#  s.preferred_dependency = 'Adding'
#  s.subspec 'Adding' do |a|
#    a.dependency 'TBXML'
#    a.dependency 'AFNetworking'
#  end
  
  s.source_files = 'Classes/**/*.*'
  s.resources    = 'Resources'/**/*.*
  s.preserve_paths = 'Resources'
  s.requires_arc = true
  s.frameworks   = 'QuartzCore', 'UIKit' , 'MapKit','Foundation', 'CoreLocation'
end

