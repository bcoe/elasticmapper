# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elastic_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "elastic_mapper"
  spec.version       = ElasticMapper::VERSION
  spec.authors       = ["Benjamin Coe"]
  spec.email         = ["bencoe@gmail.com"]
  spec.summary       = %q{A dead simple DSL for integrating ActiveModel with ElasticSearch.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "stretcher"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "activesupport"
end
