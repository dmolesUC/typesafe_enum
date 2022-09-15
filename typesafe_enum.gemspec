# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'uri'
require 'typesafe_enum/module_info'

Gem::Specification.new do |spec|
  spec.name          = TypesafeEnum::NAME
  spec.version       = TypesafeEnum::VERSION
  spec.authors       = ['Emma Hyde', 'David Moles']
  spec.email         = ['emma.hyde@dockwa.com', 'dmoles@berkeley.edu']
  spec.summary       = 'Typesafe enum pattern for Ruby'
  spec.description   = 'A gem that implements the typesafe enum pattern in Ruby: Forked from David Moles'
  spec.license       = 'MIT'

  spec.homepage = 'https://github.com/dockwa/typesafe_enum'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.11.0'
  spec.add_development_dependency 'rubocop', '~>1.36.0'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'simplecov-console', '~> 0.9.1'
  spec.add_development_dependency 'yard', '~> 0.9.28'
end
