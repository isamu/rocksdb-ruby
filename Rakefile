#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

require_relative "lib/rocksdb/ruby/version"

gem_root = File.expand_path("..", __FILE__)
librocksdb_build = File.join(gem_root, "ext", "librocksdb-build")
librocksdb_install = File.join(gem_root, "ext", "librocksdb")
rocksdb_build= File.join(gem_root, "ext", "rocksdb")
rocksdb_so = File.join(rocksdb_build, "RocksDB.#{RbConfig::MAKEFILE_CONFIG["DLEXT"]}")

# Default action is used for gem installationa
task :default => :deploy

# Build rocksdb client shared library
task :build => rocksdb_so
file rocksdb_so do
  Rake::Task[librocksdb_install].invoke
  Dir.chdir(rocksdb_build) do
    sh "ruby extconf.rb #{ENV["ROCKSDB_RUBY_BUILD_PARAMS"]}"
    sh "cp Makefile Makefile.bak; sed -e \"s/V = 0/V = 1/\" Makefile.bak > Makefile"
    sh "make"
  end
end

task :clean do
  Dir.chdir(rocksdb_build) do
    sh "make clean" if File.exist?("Makefile")
  end
end

task :clean_all => [:clean, 'librocksdb:clean_all']

task :deploy => rocksdb_so do
  # Clean temporary build files
  Rake::Task['librocksdb:clean_all'].invoke
end

# Tests
RSpec::Core::RakeTask.new("spec")
task :spec => rocksdb_so

namespace :librocksdb do
  file librocksdb_build do
    librocksdb_tag = "v#{Rocksdb::Ruby::LIBROCKSDB_VERSION}"
    librocksdb_hash = Rocksdb::Ruby::LIBROCKSDB_GIT_HASH

    dir = File.dirname(librocksdb_build)
    base = File.basename(librocksdb_build)
    Dir.chdir(dir) do
      # Checkout source
      `git clone --depth 1 --branch "#{librocksdb_tag}" https://github.com/facebook/rocksdb.git #{base}`
    end

    # Check source is at expected git hash
    Dir.chdir(librocksdb_build) do
      git_hash = `git show --format=%H --no-patch --no-abbrev-commit`.chomp
      raise "Expect librocksdb git hash to be #{librocksdb_hash}; got #{git_hash} instead" if git_hash != librocksdb_hash
    end
  end

  file librocksdb_install do
    Rake::Task['librocksdb:build'].invoke

    Dir.chdir(librocksdb_build) do
      sh "V=1 PREFIX=#{librocksdb_install} make install-static"
      sh "cat make_config.mk"
    end
  end

  task :install => librocksdb_install

  task :build => librocksdb_build do
    Dir.chdir(librocksdb_build) do
      sh "V=1 DEBUG_LEVEL=0 CFLAGS=-fPIC make -j4 static_lib"
    end
  end

  task :clean_all do
    rm_rf librocksdb_install
    rm_rf librocksdb_build
  end
end
