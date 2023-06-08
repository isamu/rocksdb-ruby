#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new('spec')
task :build do
  Dir.chdir('ext/rocksdb/') do
    output = `ruby extconf.rb #{ENV['ROCKSDB_RUBY_BUILD_PARAMS']}`
    raise output unless $? == 0
    output = `make`
    raise output unless $? == 0
  end
end

task :spec => :build

namespace :librocksdb do
  file 'ext/librocksdb' do
    Dir.chdir('ext/') do
      `git clone --depth 1 --branch v8.1.1 https://github.com/facebook/rocksdb.git librocksdb`
    end
  end

  task :build => 'ext/librocksdb' do
    Dir.chdir('ext/librocksdb/') do
      sh "V=1 DEBUG_LEVEL=0 make shared_lib"
    end
  end
end
