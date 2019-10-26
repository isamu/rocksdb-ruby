require 'rubygems'
require 'bundler/setup'
require 'tmpdir'

$: << File.dirname(__FILE__) + '/../ext/rocksdb'

RSpec.configure do |config|
  config.formatter = :documentation

  def temp_db_path
    return @_temp_db_path if defined? @_temp_db_path
    @_temp_db_path = Dir.mktmpdir("rocksdb-ruby")
  end

  def cleanup_temp_db_path
    FileUtils.remove_entry @_temp_db_path
    remove_instance_variable :@_temp_db_path
  end

  config.after(:example) do
    cleanup_temp_db_path
  end
end
