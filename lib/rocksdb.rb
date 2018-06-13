require "rocksdb/RocksDB" # the c extension
require "rocksdb/ruby/version"

module RocksDB
  class DBError < StandardError; end
  class DB
    include Enumerable

    @@cache = {}
    
    class << self
      def get_instance *args
        readonly = !!(args[1] && args[1][:readonly])
        key = args[0]
        
        if readonly
          return new(*args)
        end
        unless @@cache[key]
          @@cache[key] = new(*args)
        end
        @@cache[key]
      end
    end
    
    def initialize *args
      readonly = !!(args[1] && args[1][:readonly])
      @key = args[0]
      
      if !readonly and @@cache[@key]
        __initialize2(*args)
        raise DBError.new("error #{@key.to_s} alread open")
      end

      __initialize(*args)
      unless readonly
        @@cache[@key] = self
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
