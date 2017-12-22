
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'uri'
require 'typesafe_enum/module_info'

Gem::Specification.new do |spec|
  spec.name          = TypesafeEnum::NAME
  spec.version       = TypesafeEnum::VERSION
  spec.authors       = ['David Moles']
  spec.email         = ['david.moles@ucop.edu']
  spec.summary       = 'Typesafe enum pattern for Ruby'
  spec.description   = 'A gem that implements the typesafe enum pattern in Ruby'
  spec.license       = 'MIT'

  origin = `git config --get remote.origin.url`.chomp
  origin_uri = origin.start_with?('http') ? URI(origin) : URI(origin.gsub(%r{git@([^:]+)(.com|.org)[^\/]+}, 'http://\1\2'))
  spec.homepage = URI::HTTP.build(host: origin_uri.host, path: origin_uri.path.chomp('.git')).to_s

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'simplecov', '~> 0.9.2'
  spec.add_development_dependency 'simplecov-console', '~> 0.2.0'
  spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.12'
end
