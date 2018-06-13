require "rocksdb/RocksDB" # the c extension
require "rocksdb/ruby/version"

module RocksDB
  class DB
    include Enumerable

    @@cache = {}
    
    class << self
    end
    
    def initialize *args
      options = args[1]
      @key = args[0]
      if options && options[:readonly]
        __initialize(*args)
      else
        if @@cache[args[0]]
          __initialize2(*args)
          raise "error"
        else
          __initialize(*args)
          @@cache[args[0]] = self
        end
      end
    end

    def close
      @@cache.delete(@key)
      __close
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
