# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rocksdb/ruby/version'

Gem::Specification.new do |spec|
  spec.extensions = ["ext/rocksdb/extconf.rb"]

  spec.name          = "rocksdb-ruby"
  spec.version       = Rocksdb::Ruby::VERSION
  spec.authors       = ["Isamu Arimoto"]
  spec.email         = ["isamu.a@gmail.com"]
  spec.summary       = %q{A simple RocksDB library for Ruby}
  spec.homepage      = "https://github.com/isamu/rocksdb-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["ext", "lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-core", "~> 3.0"
end
