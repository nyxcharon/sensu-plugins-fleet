require File.expand_path(File.dirname(__FILE__)) + '/lib/sensu-plugin'

Gem::Specification.new do |s|
  s.name          = 'sensu-plugins-fleet'
  s.version       = Sensu::Plugin::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Barry Martin']
  s.email         = ['nyxcharon@gmail.com']
  s.homepage      = 'https://github.com/nyxcharon/sensu-plugins-fleet'
  s.summary       = 'Sensu Plugins'
  s.description   = 'Plugins and helper libraries for Sensu, a monitoring framework'
  s.license       = 'MIT'
  s.has_rdoc      = false
  s.require_paths = ['lib']
  s.files         = Dir.glob('{bin,lib}/**/*')
  s.test_files    = Dir['test/*.rb']

  s.add_dependency('json')
  s.add_dependency('os')
  s.add_dependency('mixlib-cli', '>= 1.1.0')

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
end
