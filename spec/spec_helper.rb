require 'rubygems'
require 'bundler/setup'

$: << File.dirname(__FILE__) + '/../ext/rocksdb'

RSpec.configure do |config|
  # some (optional) config here
end
