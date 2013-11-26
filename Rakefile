#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new('spec')
task :build do
  Dir.chdir('ext/rocksdb/') do
    output = `ruby extconf.rb`
    raise output unless $? == 0
    output = `make`
    raise output unless $? == 0
  end
end

task :spec => :build
