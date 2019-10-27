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
    extend Gem::Deprecate

    def initialize(path, rocksdb_options = "", options = {})
      is_readonly = options[:readonly] || false

      if rocksdb_options.is_a? Hash
        is_readonly = rocksdb_options[:readonly]

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

    # Deprecated methods, kept for backward compatibility
    alias_method :new_iterator, :to_iterator
    deprecate :new_iterator, :to_iterator, 2019, 12

    def is_readonly?
      !writable?
    end
    deprecate :is_readonly?, :writable?, 2019, 12

    alias_method :is_open?, :open?
    deprecate :is_open?, :open?, 2019, 12

    alias_method :multi_get, :get_many
    deprecate :multi_get, :get_many, 2019, 12
  end
end
