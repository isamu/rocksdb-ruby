require "rocksdb/RocksDB" # the c extension
require "rocksdb/ruby/version"

module RocksDB
  class Error < StandardError; end
  class ReadOnly < RocksDB::Error; end
  class StatusError < RocksDB::Error; end
  class DatabaseClosed < RocksDB::Error; end
  class IteratorClosed < RocksDB::Error; end

  class DB
    include Enumerable

    class << self
      def open(db_path, db_options = "")
        new(db_path, db_options, false)
      end

      def open_readonly(db_path, db_options = "")
        new(db_path, db_options, true)
      end
    end

    def initialize(path, db_options = "", is_readonly = false)
      __initialize(path, is_readonly, db_options.to_s)
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
    alias_method :[], :get
    alias_method :[]=, :put
    alias_method :close!, :close
    alias_method :each, :each_value
  end
end
