# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
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

  spec.homepage = 'https://github.com/dmolesUC/typesafe_enum'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop', '~> 0.74'
  spec.add_development_dependency 'simplecov', '~> 0.9.2'
  spec.add_development_dependency 'simplecov-console', '~> 0.2.0'
  spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.12'
end
