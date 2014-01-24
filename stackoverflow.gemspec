# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stackoverflow/version'

Gem::Specification.new do |spec|
  spec.name          = "stackoverflow"
  spec.version       = Stackoverflow::VERSION
  spec.authors       = ["Roman Kushnir"]
  spec.email         = ["noemail@stackoverflow.com"]
  spec.description   = %q{Ruby client for the Stackoverflow API}
  spec.summary       = %q{Ruby client for the Stackoverflow API}
  spec.homepage      = "http://github.com/CMDigital/stackoverflow"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "activesupport", ">= 3.0.0"
end
