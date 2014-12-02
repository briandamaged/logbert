
Gem::Specification.new do |s|
  s.name        = 'logbert'
  s.version     = '1.0.2'
  s.date        = '2014-04-29'
  s.summary     = "Logging for winners."
  s.description = "Change your logging behaviors without mucking with your code!"
  s.authors     = ["Brian Lauber"]
  s.email       = 'constructible.truth@gmail.com'
  s.files       = Dir["lib/**/*.rb"]
  s.license     = "MIT"

  s.add_runtime_dependency 'lockfile', '~> 2.1.3'
  s.add_runtime_dependency 'redis', '~> 3.1.0'
end

