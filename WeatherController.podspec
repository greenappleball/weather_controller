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

  s.subspec 'Addition' do |a|
    a.source_files = 'Classes/Addition/**/*.*'
    a.requires_arc = false
  end
  
  s.subspec 'CustomWeatherClient' do |c|
    c.source_files = 'Classes/CustomWeatherClient/**/*.*'
  end

  s.subspec 'Proxy' do |p|
    p.source_files = 'Classes/Proxy/**/*.*'
  end

  s.subspec 'UI' do |u|
    u.source_files = 'Classes/UI/**/*.*'
  end

  s.source_files = 'Classes/*.*'
  s.resources    = 'Resources/**/*.*'
  s.preserve_paths = 'Resources'
  s.requires_arc = true
  s.frameworks   = 'QuartzCore', 'UIKit' , 'MapKit','Foundation', 'CoreLocation'

  s.dependency 'AFNetworking'
  s.dependency 'TBXML'
end

