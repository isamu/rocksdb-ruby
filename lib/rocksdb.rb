require "rocksdb/RocksDB" # the c extension
require "rocksdb/ruby/version"

module RocksDB
  class DB
    include Enumerable
    
    class << self
    end
    
    alias :includes? :exists?
    alias :contains? :exists?
    alias :member? :exists?
    alias :[] :get
    alias :[]= :put
    alias :close! :close

    def each(&block)
      if block_given?
        self.each_with_index do |key, value|
          block.call(value)
        end
      else
        self.iterator
      end
    end
  end
end
