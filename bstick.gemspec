# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bstick/version'

Gem::Specification.new do |spec|
  spec.name          = "bstick"
  spec.version       = Bstick::VERSION
  spec.authors       = ["bseverac"]
  spec.email         = ["bseverac@gmail.com"]

  spec.summary       = "Blinkstick server watching file state and utilities"
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = ["lib/bstick.rb", "lib/bstick/version.rb", "lib/blinkstick.rb"]
  spec.bindir        = "bin"
  spec.executables   << "bstick"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "color", "~> 1.8"
  spec.add_development_dependency "libusb", "~> 0.5"
  spec.add_development_dependency "net-ping", "~> 2.0"
  spec.add_development_dependency "daemons", "~> 1.2"
end
