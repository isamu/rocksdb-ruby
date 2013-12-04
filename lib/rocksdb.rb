require "RocksDB/RocksDB" # the c extension
require "rocksdb/ruby/version"

module RocksDB
  class DB
    class << self
    end

    alias :includes? :exists?
    alias :contains? :exists?
    alias :member? :exists?
    alias :[] :get
    alias :[]= :put
    alias :close! :close
  end
end
