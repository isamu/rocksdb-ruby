require "rocksdb/RocksDB" # the c extension
require "rocksdb/ruby/version"

require 'forwardable'

module RocksDB
  class Error < StandardError; end
  class ReadOnly < RocksDB::Error; end
  class StatusError < RocksDB::Error; end
  class DatabaseClosed < RocksDB::Error; end
  class IteratorClosed < RocksDB::Error; end

  class Iterator
    include Enumerable
  end

  class << self
    def open(db_path, db_options = "")
      ::RocksDB::DB.new(db_path, db_options, readonly: false)
    end

    def open_readonly(db_path, db_options = "")
      ::RocksDB::DB.new(db_path, db_options, readonly: true)
    end
  end

  class DB
    extend Forwardable

    def initialize(path, rocksdb_options = "", options = {})
      is_readonly = options[:readonly] || false

      if rocksdb_options.is_a? Hash
        rocksdb_options = rocksdb_options.map do |key, value|
          [key, value].join("=")
        end.join(";")
      end

      __initialize(path, is_readonly, rocksdb_options.to_s)
    end

    def get(*args)
      args.flatten!

      if args.size == 1
        get_one args.first
      else
        get_many args
      end
    end

    def options
      options_strings.each_with_object({}) do |(option_group, value), result|
        pairs = value.split(/;\s*/)
        pairs.map do |pair|
          key, value = pair.split("=")
          result[key] = value
        end
      end
    end

    alias_method :includes?, :exists?
    alias_method :contains?, :exists?
    alias_method :member?, :exists?
    alias_method :member?, :exists?
    alias_method :[], :get
    alias_method :[]=, :put
    alias_method :close!, :close

    def_delegators :to_iterator,
                   :each, :reverse_each, :each_key, :reverse_each_key,
                   :each_pair, :reverse_each_pair,
                   :each_prefix, :each_range

    alias_method :each_index, :each_key
    alias_method :each_with_index, :each_pair
  end
end

require 'rocksdb/ruby/deprecated'
